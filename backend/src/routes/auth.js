const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Joi = require("joi");
const { pool } = require("../config/database");

const router = express.Router();

// Validation schemas
const loginSchema = Joi.object({
  email: Joi.string().email().optional(),
  password: Joi.string().min(6).optional(),
  yandexId: Joi.string().optional(),
  isGuest: Joi.boolean().optional(),
}).or("email", "yandexId", "isGuest");

const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  name: Joi.string().min(2).max(50).required(),
});

// Generate JWT tokens
const generateTokens = (playerId) => {
  const accessToken = jwt.sign(
    { playerId, type: "access" },
    process.env.JWT_SECRET,
    { expiresIn: "1h" }
  );

  const refreshToken = jwt.sign(
    { playerId, type: "refresh" },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: "7d" }
  );

  return { accessToken, refreshToken };
};

// Login endpoint
router.post("/login", async (req, res) => {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: "Validation error",
        message: error.details[0].message,
      });
    }

    const { email, password, yandexId, isGuest } = value;

    // Guest login
    if (isGuest) {
      const guestId = `guest_${Date.now()}_${Math.random()
        .toString(36)
        .substr(2, 9)}`;
      const guestPlayer = {
        id: guestId,
        name: `Гость ${Math.floor(Math.random() * 1000)}`,
        email: null,
        totalScore: 0,
        level: 1,
        coins: 0,
        skins: ["1"],
        currentSkin: "1",
        isGuest: true,
        lastSyncAt: null,
      };

      const tokens = generateTokens(guestId);

      return res.json({
        success: true,
        data: {
          player: guestPlayer,
          token: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        },
      });
    }

    // Regular login
    if (email && password) {
      const result = await pool.query(
        "SELECT * FROM players WHERE email = $1",
        [email]
      );

      if (result.rows.length === 0) {
        return res.status(401).json({
          success: false,
          error: "Invalid credentials",
          message: "Email or password is incorrect",
        });
      }

      const player = result.rows[0];
      const isValidPassword = await bcrypt.compare(
        password,
        player.password_hash
      );

      if (!isValidPassword) {
        return res.status(401).json({
          success: false,
          error: "Invalid credentials",
          message: "Email or password is incorrect",
        });
      }

      const tokens = generateTokens(player.id);

      // Update last login
      await pool.query(
        "UPDATE players SET last_login_at = NOW() WHERE id = $1",
        [player.id]
      );

      return res.json({
        success: true,
        data: {
          player: {
            id: player.id,
            name: player.name,
            email: player.email,
            avatar: player.avatar,
            totalScore: player.total_score,
            level: player.level,
            coins: player.coins,
            skins: player.skins || ["1"],
            currentSkin: player.current_skin || "1",
            isGuest: false,
            lastSyncAt: player.last_sync_at,
          },
          token: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        },
      });
    }

    // Yandex ID login (placeholder)
    if (yandexId) {
      return res.status(501).json({
        success: false,
        error: "Not implemented",
        message: "Yandex ID login will be implemented in future versions",
      });
    }

    res.status(400).json({
      success: false,
      error: "Invalid request",
      message: "Provide email/password, yandexId, or isGuest flag",
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({
      success: false,
      error: "Internal server error",
      message: "Failed to process login request",
    });
  }
});

// Register endpoint
router.post("/register", async (req, res) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: "Validation error",
        message: error.details[0].message,
      });
    }

    const { email, password, name } = value;

    // Check if user already exists
    const existingUser = await pool.query(
      "SELECT id FROM players WHERE email = $1",
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        error: "User already exists",
        message: "An account with this email already exists",
      });
    }

    // Hash password
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user
    const result = await pool.query(
      `INSERT INTO players (name, email, password_hash, total_score, level, coins, skins, current_skin, is_guest, created_at, last_sync_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())
       RETURNING id, name, email, avatar, total_score, level, coins, skins, current_skin, is_guest, last_sync_at`,
      [name, email, passwordHash, 0, 1, 0, ["1"], "1", false]
    );

    const player = result.rows[0];
    const tokens = generateTokens(player.id);

    res.status(201).json({
      success: true,
      data: {
        player: {
          id: player.id,
          name: player.name,
          email: player.email,
          avatar: player.avatar,
          totalScore: player.total_score,
          level: player.level,
          coins: player.coins,
          skins: player.skins,
          currentSkin: player.current_skin,
          isGuest: player.is_guest,
          lastSyncAt: player.last_sync_at,
        },
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      },
    });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({
      success: false,
      error: "Internal server error",
      message: "Failed to create account",
    });
  }
});

// Refresh token endpoint
router.post("/refresh", async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        error: "Refresh token required",
        message: "Refresh token is missing",
      });
    }

    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

    if (decoded.type !== "refresh") {
      return res.status(401).json({
        success: false,
        error: "Invalid token type",
        message: "Invalid refresh token",
      });
    }

    const tokens = generateTokens(decoded.playerId);

    res.json({
      success: true,
      data: {
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      },
    });
  } catch (error) {
    console.error("Token refresh error:", error);
    res.status(401).json({
      success: false,
      error: "Invalid refresh token",
      message: "Refresh token is invalid or expired",
    });
  }
});

// Logout endpoint
router.post("/logout", async (req, res) => {
  // In a real application, you might want to blacklist the token
  // For now, we'll just return success
  res.json({
    success: true,
    message: "Logged out successfully",
  });
});

module.exports = router;
