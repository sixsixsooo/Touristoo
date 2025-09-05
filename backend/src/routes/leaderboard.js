const express = require("express");
const router = express.Router();
const { pool } = require("../config/database");
const { optionalAuth } = require("../middleware/auth");

// Get leaderboard entries
router.get("/", optionalAuth, async (req, res) => {
  try {
    const {
      range = "all",
      limit = 50,
      offset = 0,
      sortBy = "score", // score, distance, level
    } = req.query;

    // Validate parameters
    if (!["all", "daily", "weekly", "monthly"].includes(range)) {
      return res.status(400).json({ error: "Invalid time range" });
    }

    if (!["score", "distance", "level"].includes(sortBy)) {
      return res.status(400).json({ error: "Invalid sort field" });
    }

    // Calculate time filter
    let timeFilter = "";
    const now = new Date();
    switch (range) {
      case "daily":
        timeFilter = `AND l.created_at >= '${now.toISOString().split("T")[0]}'`;
        break;
      case "weekly":
        const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        timeFilter = `AND l.created_at >= '${weekAgo.toISOString()}'`;
        break;
      case "monthly":
        const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        timeFilter = `AND l.created_at >= '${monthAgo.toISOString()}'`;
        break;
    }

    // Get leaderboard entries with player info
    const result = await pool.query(
      `SELECT 
        l.id,
        l.score,
        l.distance,
        l.level,
        l.created_at,
        p.username,
        p.avatar,
        p.level as player_level,
        ROW_NUMBER() OVER (ORDER BY l.${sortBy} DESC) as rank
       FROM leaderboard l
       LEFT JOIN players p ON l.player_id = p.id
       WHERE l.time_range = $1 ${timeFilter}
       ORDER BY l.${sortBy} DESC
       LIMIT $2 OFFSET $3`,
      [range, parseInt(limit), parseInt(offset)]
    );

    // Get total count for pagination
    const countResult = await pool.query(
      `SELECT COUNT(*) as total
       FROM leaderboard l
       WHERE l.time_range = $1 ${timeFilter}`,
      [range]
    );

    const total = parseInt(countResult.rows[0].total);

    res.json({
      success: true,
      data: {
        entries: result.rows.map((entry) => ({
          id: entry.id,
          rank: entry.rank,
          score: entry.score,
          distance: entry.distance,
          level: entry.level,
          player: {
            username: entry.username || "Guest",
            avatar: entry.avatar,
            level: entry.player_level,
          },
          createdAt: entry.created_at,
        })),
        pagination: {
          total,
          limit: parseInt(limit),
          offset: parseInt(offset),
          hasMore: parseInt(offset) + parseInt(limit) < total,
        },
        timeRange: range,
        sortBy,
      },
    });
  } catch (error) {
    console.error("Error fetching leaderboard:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get player's rank
router.get("/rank", optionalAuth, async (req, res) => {
  try {
    const { range = "all", sortBy = "score" } = req.query;
    const playerId = req.user ? req.user.playerId : null;

    if (!playerId) {
      return res.status(401).json({ error: "Authentication required" });
    }

    // Validate parameters
    if (!["all", "daily", "weekly", "monthly"].includes(range)) {
      return res.status(400).json({ error: "Invalid time range" });
    }

    if (!["score", "distance", "level"].includes(sortBy)) {
      return res.status(400).json({ error: "Invalid sort field" });
    }

    // Calculate time filter
    let timeFilter = "";
    const now = new Date();
    switch (range) {
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

    // Get player's best entry and rank
    const result = await pool.query(
      `WITH player_entry AS (
        SELECT score, distance, level, created_at
        FROM leaderboard 
        WHERE player_id = $1 AND time_range = $2 ${timeFilter}
        ORDER BY ${sortBy} DESC
        LIMIT 1
      ),
      rank_calculation AS (
        SELECT COUNT(*) + 1 as rank
        FROM leaderboard l
        WHERE l.time_range = $2 AND l.${sortBy} > (SELECT ${sortBy} FROM player_entry) ${timeFilter}
      )
      SELECT 
        pe.score,
        pe.distance,
        pe.level,
        pe.created_at,
        rc.rank
      FROM player_entry pe
      CROSS JOIN rank_calculation rc`,
      [playerId, range]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "No entries found for player" });
    }

    const entry = result.rows[0];
    res.json({
      success: true,
      data: {
        rank: parseInt(entry.rank),
        score: entry.score,
        distance: entry.distance,
        level: entry.level,
        createdAt: entry.created_at,
        timeRange: range,
        sortBy,
      },
    });
  } catch (error) {
    console.error("Error fetching player rank:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get leaderboard statistics
router.get("/stats", async (req, res) => {
  try {
    const { range = "all" } = req.query;

    // Validate parameters
    if (!["all", "daily", "weekly", "monthly"].includes(range)) {
      return res.status(400).json({ error: "Invalid time range" });
    }

    // Calculate time filter
    let timeFilter = "";
    const now = new Date();
    switch (range) {
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

    // Get statistics
    const result = await pool.query(
      `SELECT 
        COUNT(*) as total_entries,
        COUNT(DISTINCT player_id) as unique_players,
        AVG(score) as average_score,
        MAX(score) as highest_score,
        AVG(distance) as average_distance,
        MAX(distance) as highest_distance,
        AVG(level) as average_level,
        MAX(level) as highest_level
       FROM leaderboard 
       WHERE time_range = $1 ${timeFilter}`,
      [range]
    );

    const stats = result.rows[0];
    res.json({
      success: true,
      data: {
        totalEntries: parseInt(stats.total_entries),
        uniquePlayers: parseInt(stats.unique_players),
        averageScore: parseFloat(stats.average_score) || 0,
        highestScore: parseInt(stats.highest_score) || 0,
        averageDistance: parseFloat(stats.average_distance) || 0,
        highestDistance: parseInt(stats.highest_distance) || 0,
        averageLevel: parseFloat(stats.average_level) || 0,
        highestLevel: parseInt(stats.highest_level) || 0,
        timeRange: range,
      },
    });
  } catch (error) {
    console.error("Error fetching leaderboard stats:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get top players by different criteria
router.get("/top", async (req, res) => {
  try {
    const {
      range = "all",
      criteria = "score", // score, distance, level, coins
      limit = 10,
    } = req.query;

    // Validate parameters
    if (!["all", "daily", "weekly", "monthly"].includes(range)) {
      return res.status(400).json({ error: "Invalid time range" });
    }

    if (!["score", "distance", "level", "coins"].includes(criteria)) {
      return res.status(400).json({ error: "Invalid criteria" });
    }

    // Calculate time filter
    let timeFilter = "";
    const now = new Date();
    switch (range) {
      case "daily":
        timeFilter = `AND l.created_at >= '${now.toISOString().split("T")[0]}'`;
        break;
      case "weekly":
        const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        timeFilter = `AND l.created_at >= '${weekAgo.toISOString()}'`;
        break;
      case "monthly":
        const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        timeFilter = `AND l.created_at >= '${monthAgo.toISOString()}'`;
        break;
    }

    let orderBy = "";
    if (criteria === "coins") {
      orderBy = "p.total_coins DESC";
    } else {
      orderBy = `l.${criteria} DESC`;
    }

    // Get top players
    const result = await pool.query(
      `SELECT 
        p.id,
        p.username,
        p.avatar,
        p.level,
        p.total_coins,
        l.score,
        l.distance,
        l.level as entry_level,
        ROW_NUMBER() OVER (ORDER BY ${orderBy}) as rank
       FROM players p
       LEFT JOIN leaderboard l ON p.id = l.player_id AND l.time_range = $1 ${timeFilter}
       WHERE p.id IS NOT NULL
       ORDER BY ${orderBy}
       LIMIT $2`,
      [range, parseInt(limit)]
    );

    res.json({
      success: true,
      data: {
        players: result.rows.map((player) => ({
          id: player.id,
          username: player.username,
          avatar: player.avatar,
          level: player.level,
          totalCoins: player.total_coins,
          bestScore: player.score || 0,
          bestDistance: player.distance || 0,
          bestLevel: player.entry_level || 0,
          rank: player.rank,
        })),
        criteria,
        timeRange: range,
      },
    });
  } catch (error) {
    console.error("Error fetching top players:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
