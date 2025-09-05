const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { pool } = require("../config/database");
const { authenticateToken } = require("../middleware/auth");

// Validation schemas
const updateProfileSchema = Joi.object({
  username: Joi.string().min(3).max(30).optional(),
  email: Joi.string().email().optional(),
  avatar: Joi.string().uri().optional(),
  settings: Joi.object({
    soundEnabled: Joi.boolean().optional(),
    musicEnabled: Joi.boolean().optional(),
    vibrationEnabled: Joi.boolean().optional(),
    graphicsQuality: Joi.string().valid("low", "medium", "high").optional(),
    controlsSensitivity: Joi.number().min(0.1).max(2.0).optional(),
  }).optional(),
});

const purchaseSchema = Joi.object({
  itemId: Joi.string().required(),
  itemType: Joi.string().valid("skin", "booster", "currency").required(),
  price: Joi.number().min(0).required(),
  currency: Joi.string().valid("coins", "real_money").required(),
  transactionId: Joi.string().optional(),
});

// Get player profile
router.get("/profile", authenticateToken, async (req, res) => {
  try {
    const { playerId } = req.user;

    const result = await pool.query(
      `SELECT 
        id, username, email, avatar, 
        total_score, best_distance, total_coins, 
        level, experience, achievements,
        settings, created_at, last_login
       FROM players WHERE id = $1`,
      [playerId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Player not found" });
    }

    const player = result.rows[0];
    res.json({
      success: true,
      data: {
        id: player.id,
        username: player.username,
        email: player.email,
        avatar: player.avatar,
        stats: {
          totalScore: player.total_score,
          bestDistance: player.best_distance,
          totalCoins: player.total_coins,
          level: player.level,
          experience: player.experience,
        },
        achievements: player.achievements || [],
        settings: player.settings || {},
        createdAt: player.created_at,
        lastLogin: player.last_login,
      },
    });
  } catch (error) {
    console.error("Error fetching player profile:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Update player profile
router.put("/profile", authenticateToken, async (req, res) => {
  try {
    const { error, value } = updateProfileSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { playerId } = req.user;
    const { username, email, avatar, settings } = value;

    // Build dynamic update query
    const updates = [];
    const values = [];
    let paramCount = 1;

    if (username) {
      updates.push(`username = $${paramCount++}`);
      values.push(username);
    }
    if (email) {
      updates.push(`email = $${paramCount++}`);
      values.push(email);
    }
    if (avatar) {
      updates.push(`avatar = $${paramCount++}`);
      values.push(avatar);
    }
    if (settings) {
      updates.push(`settings = $${paramCount++}`);
      values.push(JSON.stringify(settings));
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: "No valid fields to update" });
    }

    updates.push(`updated_at = NOW()`);
    values.push(playerId);

    const query = `UPDATE players SET ${updates.join(
      ", "
    )} WHERE id = $${paramCount}`;

    await pool.query(query, values);

    res.json({ success: true, message: "Profile updated successfully" });
  } catch (error) {
    console.error("Error updating player profile:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get player statistics
router.get("/stats", authenticateToken, async (req, res) => {
  try {
    const { playerId } = req.user;

    const result = await pool.query(
      `SELECT 
        total_score, best_distance, total_coins, 
        level, experience, achievements,
        (SELECT COUNT(*) FROM game_sessions WHERE player_id = $1) as games_played,
        (SELECT AVG(score) FROM game_sessions WHERE player_id = $1) as average_score
       FROM players WHERE id = $1`,
      [playerId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Player not found" });
    }

    const stats = result.rows[0];
    res.json({
      success: true,
      data: {
        totalScore: stats.total_score,
        bestDistance: stats.best_distance,
        totalCoins: stats.total_coins,
        level: stats.level,
        experience: stats.experience,
        gamesPlayed: parseInt(stats.games_played),
        averageScore: parseFloat(stats.average_score) || 0,
        achievements: stats.achievements || [],
      },
    });
  } catch (error) {
    console.error("Error fetching player stats:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get player purchases
router.get("/purchases", authenticateToken, async (req, res) => {
  try {
    const { playerId } = req.user;
    const { limit = 50, offset = 0 } = req.query;

    const result = await pool.query(
      `SELECT id, item_id, item_type, price, currency, 
              transaction_id, created_at, status
       FROM purchases 
       WHERE player_id = $1 
       ORDER BY created_at DESC 
       LIMIT $2 OFFSET $3`,
      [playerId, parseInt(limit), parseInt(offset)]
    );

    res.json({
      success: true,
      data: result.rows.map((purchase) => ({
        id: purchase.id,
        itemId: purchase.item_id,
        itemType: purchase.item_type,
        price: purchase.price,
        currency: purchase.currency,
        transactionId: purchase.transaction_id,
        status: purchase.status,
        createdAt: purchase.created_at,
      })),
    });
  } catch (error) {
    console.error("Error fetching player purchases:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Record a purchase
router.post("/purchases", authenticateToken, async (req, res) => {
  try {
    const { error, value } = purchaseSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { playerId } = req.user;
    const { itemId, itemType, price, currency, transactionId } = value;

    // Start transaction
    const client = await pool.connect();
    try {
      await client.query("BEGIN");

      // Insert purchase record
      const purchaseResult = await client.query(
        `INSERT INTO purchases (player_id, item_id, item_type, price, currency, transaction_id, status)
         VALUES ($1, $2, $3, $4, $5, $6, 'completed')
         RETURNING id, created_at`,
        [playerId, itemId, itemType, price, currency, transactionId]
      );

      // Update player coins if currency purchase
      if (itemType === "currency" && currency === "coins") {
        await client.query(
          "UPDATE players SET total_coins = total_coins + $1 WHERE id = $2",
          [price, playerId]
        );
      }

      await client.query("COMMIT");

      const purchase = purchaseResult.rows[0];
      res.status(201).json({
        success: true,
        data: {
          id: purchase.id,
          itemId,
          itemType,
          price,
          currency,
          transactionId,
          status: "completed",
          createdAt: purchase.created_at,
        },
      });
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Error recording purchase:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get player achievements
router.get("/achievements", authenticateToken, async (req, res) => {
  try {
    const { playerId } = req.user;

    const result = await pool.query(
      `SELECT achievements FROM players WHERE id = $1`,
      [playerId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Player not found" });
    }

    const achievements = result.rows[0].achievements || [];
    res.json({
      success: true,
      data: achievements,
    });
  } catch (error) {
    console.error("Error fetching player achievements:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Update player achievements
router.put("/achievements", authenticateToken, async (req, res) => {
  try {
    const { achievements } = req.body;

    if (!Array.isArray(achievements)) {
      return res.status(400).json({ error: "Achievements must be an array" });
    }

    const { playerId } = req.user;

    await pool.query(
      "UPDATE players SET achievements = $1, updated_at = NOW() WHERE id = $2",
      [JSON.stringify(achievements), playerId]
    );

    res.json({ success: true, message: "Achievements updated successfully" });
  } catch (error) {
    console.error("Error updating player achievements:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
