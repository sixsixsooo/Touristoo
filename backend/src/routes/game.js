const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { pool } = require("../config/database");
const { authenticateToken, optionalAuth } = require("../middleware/auth");

// Validation schemas
const syncGameDataSchema = Joi.object({
  score: Joi.number().min(0).required(),
  distance: Joi.number().min(0).required(),
  coins: Joi.number().min(0).required(),
  level: Joi.number().min(1).required(),
  experience: Joi.number().min(0).required(),
  achievements: Joi.array().items(Joi.string()).optional(),
  gameSession: Joi.object({
    duration: Joi.number().min(0).required(),
    obstaclesHit: Joi.number().min(0).required(),
    coinsCollected: Joi.number().min(0).required(),
    powerUpsUsed: Joi.number().min(0).required(),
  }).optional(),
});

const leaderboardEntrySchema = Joi.object({
  score: Joi.number().min(0).required(),
  distance: Joi.number().min(0).required(),
  level: Joi.number().min(1).required(),
});

// Sync game data (progress, achievements, etc.)
router.post("/sync", authenticateToken, async (req, res) => {
  try {
    const { error, value } = syncGameDataSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { playerId } = req.user;
    const {
      score,
      distance,
      coins,
      level,
      experience,
      achievements,
      gameSession,
    } = value;

    const client = await pool.connect();
    try {
      await client.query("BEGIN");

      // Update player stats
      await client.query(
        `UPDATE players SET 
          total_score = GREATEST(total_score, $1),
          best_distance = GREATEST(best_distance, $2),
          total_coins = total_coins + $3,
          level = GREATEST(level, $4),
          experience = $5,
          achievements = COALESCE($6, achievements),
          updated_at = NOW()
         WHERE id = $7`,
        [
          score,
          distance,
          coins,
          level,
          experience,
          achievements ? JSON.stringify(achievements) : null,
          playerId,
        ]
      );

      // Record game session if provided
      if (gameSession) {
        await client.query(
          `INSERT INTO game_sessions (player_id, score, distance, duration, 
           obstacles_hit, coins_collected, power_ups_used, created_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())`,
          [
            playerId,
            score,
            distance,
            gameSession.duration,
            gameSession.obstaclesHit,
            gameSession.coinsCollected,
            gameSession.powerUpsUsed,
          ]
        );
      }

      await client.query("COMMIT");

      res.json({
        success: true,
        message: "Game data synchronized successfully",
      });
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Error syncing game data:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Submit score to leaderboard
router.post("/leaderboard", optionalAuth, async (req, res) => {
  try {
    const { error, value } = leaderboardEntrySchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { score, distance, level } = value;
    const playerId = req.user ? req.user.playerId : null;
    const timeRange = req.query.range || "all"; // all, daily, weekly, monthly

    // Calculate time filter
    let timeFilter = "";
    const now = new Date();
    switch (timeRange) {
      case "daily":
        timeFilter = `AND created_at >= '${now.toISOString().split("T")[0]}'`;
        break;
      case "weekly":
        const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        timeFilter = `AND created_at >= '${weekAgo.toISOString()}'`;
        break;
      case "monthly":
        const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        timeFilter = `AND created_at >= '${monthAgo.toISOString()}'`;
        break;
    }

    const client = await pool.connect();
    try {
      await client.query("BEGIN");

      // Insert leaderboard entry
      const result = await client.query(
        `INSERT INTO leaderboard (player_id, score, distance, level, time_range, created_at)
         VALUES ($1, $2, $3, $4, $5, NOW())
         RETURNING id`,
        [playerId, score, distance, level, timeRange]
      );

      // Get player's rank
      const rankResult = await client.query(
        `SELECT COUNT(*) + 1 as rank 
         FROM leaderboard 
         WHERE time_range = $1 AND score > $2 ${timeFilter}`,
        [timeRange, score]
      );

      await client.query("COMMIT");

      res.json({
        success: true,
        data: {
          entryId: result.rows[0].id,
          rank: parseInt(rankResult.rows[0].rank),
          timeRange,
        },
      });
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Error submitting to leaderboard:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get game statistics
router.get("/stats", optionalAuth, async (req, res) => {
  try {
    const playerId = req.user ? req.user.playerId : null;
    const timeRange = req.query.range || "all";

    let timeFilter = "";
    const now = new Date();
    switch (timeRange) {
      case "daily":
        timeFilter = `AND created_at >= '${now.toISOString().split("T")[0]}'`;
        break;
      case "weekly":
        const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        timeFilter = `AND created_at >= '${weekAgo.toISOString()}'`;
        break;
      case "monthly":
        const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        timeFilter = `AND created_at >= '${monthAgo.toISOString()}'`;
        break;
    }

    // Get global stats
    const globalStats = await pool.query(
      `SELECT 
        COUNT(*) as total_players,
        AVG(score) as average_score,
        MAX(score) as highest_score,
        AVG(distance) as average_distance,
        MAX(distance) as highest_distance
       FROM leaderboard 
       WHERE time_range = $1 ${timeFilter}`,
      [timeRange]
    );

    // Get player's personal stats if authenticated
    let playerStats = null;
    if (playerId) {
      const playerResult = await pool.query(
        `SELECT 
          COUNT(*) as games_played,
          AVG(score) as average_score,
          MAX(score) as best_score,
          AVG(distance) as average_distance,
          MAX(distance) as best_distance,
          AVG(duration) as average_duration
         FROM game_sessions 
         WHERE player_id = $1 ${timeFilter}`,
        [playerId]
      );

      if (playerResult.rows.length > 0) {
        const stats = playerResult.rows[0];
        playerStats = {
          gamesPlayed: parseInt(stats.games_played),
          averageScore: parseFloat(stats.average_score) || 0,
          bestScore: parseInt(stats.best_score) || 0,
          averageDistance: parseFloat(stats.average_distance) || 0,
          bestDistance: parseInt(stats.best_distance) || 0,
          averageDuration: parseFloat(stats.average_duration) || 0,
        };
      }
    }

    const stats = globalStats.rows[0];
    res.json({
      success: true,
      data: {
        global: {
          totalPlayers: parseInt(stats.total_players),
          averageScore: parseFloat(stats.average_score) || 0,
          highestScore: parseInt(stats.highest_score) || 0,
          averageDistance: parseFloat(stats.average_distance) || 0,
          highestDistance: parseInt(stats.highest_distance) || 0,
        },
        player: playerStats,
        timeRange,
      },
    });
  } catch (error) {
    console.error("Error fetching game stats:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get game session history
router.get("/sessions", authenticateToken, async (req, res) => {
  try {
    const { playerId } = req.user;
    const { limit = 20, offset = 0 } = req.query;

    const result = await pool.query(
      `SELECT id, score, distance, duration, obstacles_hit, 
              coins_collected, power_ups_used, created_at
       FROM game_sessions 
       WHERE player_id = $1 
       ORDER BY created_at DESC 
       LIMIT $2 OFFSET $3`,
      [playerId, parseInt(limit), parseInt(offset)]
    );

    res.json({
      success: true,
      data: result.rows.map((session) => ({
        id: session.id,
        score: session.score,
        distance: session.distance,
        duration: session.duration,
        obstaclesHit: session.obstacles_hit,
        coinsCollected: session.coins_collected,
        powerUpsUsed: session.power_ups_used,
        createdAt: session.created_at,
      })),
    });
  } catch (error) {
    console.error("Error fetching game sessions:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
