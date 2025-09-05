const express = require("express");
const router = express.Router();
const { pool } = require("../config/database");

// Get asset URL by type and name
router.get("/:type/:name", async (req, res) => {
  try {
    const { type, name } = req.params;
    const { quality = "medium" } = req.query;

    // Validate asset type
    const validTypes = ["models", "textures", "sounds", "animations", "ui"];
    if (!validTypes.includes(type)) {
      return res.status(400).json({ error: "Invalid asset type" });
    }

    // Validate quality
    const validQualities = ["low", "medium", "high"];
    if (!validQualities.includes(quality)) {
      return res.status(400).json({ error: "Invalid quality setting" });
    }

    // Get asset from database
    const result = await pool.query(
      `SELECT 
        id, name, type, quality, url, size, format, 
        created_at, updated_at, metadata
       FROM assets 
       WHERE type = $1 AND name = $2 AND quality = $3
       ORDER BY created_at DESC
       LIMIT 1`,
      [type, name, quality]
    );

    if (result.rows.length === 0) {
      // Try to find any quality version if specific quality not found
      const fallbackResult = await pool.query(
        `SELECT 
          id, name, type, quality, url, size, format, 
          created_at, updated_at, metadata
         FROM assets 
         WHERE type = $1 AND name = $2
         ORDER BY 
           CASE quality 
             WHEN 'high' THEN 1 
             WHEN 'medium' THEN 2 
             WHEN 'low' THEN 3 
             ELSE 4 
           END,
           created_at DESC
         LIMIT 1`,
        [type, name]
      );

      if (fallbackResult.rows.length === 0) {
        return res.status(404).json({ error: "Asset not found" });
      }

      const asset = fallbackResult.rows[0];
      return res.json({
        success: true,
        data: {
          id: asset.id,
          name: asset.name,
          type: asset.type,
          quality: asset.quality,
          url: asset.url,
          size: asset.size,
          format: asset.format,
          metadata: asset.metadata || {},
          createdAt: asset.created_at,
          updatedAt: asset.updated_at,
        },
      });
    }

    const asset = result.rows[0];
    res.json({
      success: true,
      data: {
        id: asset.id,
        name: asset.name,
        type: asset.type,
        quality: asset.quality,
        url: asset.url,
        size: asset.size,
        format: asset.format,
        metadata: asset.metadata || {},
        createdAt: asset.created_at,
        updatedAt: asset.updated_at,
      },
    });
  } catch (error) {
    console.error("Error fetching asset:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get all assets by type
router.get("/:type", async (req, res) => {
  try {
    const { type } = req.params;
    const { quality = "medium", limit = 100, offset = 0 } = req.query;

    // Validate asset type
    const validTypes = ["models", "textures", "sounds", "animations", "ui"];
    if (!validTypes.includes(type)) {
      return res.status(400).json({ error: "Invalid asset type" });
    }

    // Validate quality
    const validQualities = ["low", "medium", "high"];
    if (!validQualities.includes(quality)) {
      return res.status(400).json({ error: "Invalid quality setting" });
    }

    // Get assets
    const result = await pool.query(
      `SELECT 
        id, name, type, quality, url, size, format, 
        created_at, updated_at, metadata
       FROM assets 
       WHERE type = $1 AND quality = $2
       ORDER BY name ASC
       LIMIT $3 OFFSET $4`,
      [type, quality, parseInt(limit), parseInt(offset)]
    );

    // Get total count
    const countResult = await pool.query(
      `SELECT COUNT(*) as total
       FROM assets 
       WHERE type = $1 AND quality = $2`,
      [type, quality]
    );

    const total = parseInt(countResult.rows[0].total);

    res.json({
      success: true,
      data: {
        assets: result.rows.map((asset) => ({
          id: asset.id,
          name: asset.name,
          type: asset.type,
          quality: asset.quality,
          url: asset.url,
          size: asset.size,
          format: asset.format,
          metadata: asset.metadata || {},
          createdAt: asset.created_at,
          updatedAt: asset.updated_at,
        })),
        pagination: {
          total,
          limit: parseInt(limit),
          offset: parseInt(offset),
          hasMore: parseInt(offset) + parseInt(limit) < total,
        },
        type,
        quality,
      },
    });
  } catch (error) {
    console.error("Error fetching assets:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get asset manifest (all available assets)
router.get("/", async (req, res) => {
  try {
    const { quality = "medium" } = req.query;

    // Validate quality
    const validQualities = ["low", "medium", "high"];
    if (!validQualities.includes(quality)) {
      return res.status(400).json({ error: "Invalid quality setting" });
    }

    // Get all assets grouped by type
    const result = await pool.query(
      `SELECT 
        type,
        JSON_AGG(
          JSON_BUILD_OBJECT(
            'id', id,
            'name', name,
            'quality', quality,
            'url', url,
            'size', size,
            'format', format,
            'metadata', COALESCE(metadata, '{}'::json),
            'createdAt', created_at,
            'updatedAt', updated_at
          ) ORDER BY name
        ) as assets
       FROM assets 
       WHERE quality = $1
       GROUP BY type
       ORDER BY type`,
      [quality]
    );

    const manifest = {};
    result.rows.forEach((row) => {
      manifest[row.type] = row.assets;
    });

    res.json({
      success: true,
      data: {
        manifest,
        quality,
        totalTypes: result.rows.length,
        totalAssets: result.rows.reduce(
          (sum, row) => sum + row.assets.length,
          0
        ),
      },
    });
  } catch (error) {
    console.error("Error fetching asset manifest:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Get asset statistics
router.get("/stats/overview", async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
        type,
        quality,
        COUNT(*) as count,
        SUM(size) as total_size,
        AVG(size) as average_size
       FROM assets 
       GROUP BY type, quality
       ORDER BY type, quality`
    );

    const stats = {};
    result.rows.forEach((row) => {
      if (!stats[row.type]) {
        stats[row.type] = {};
      }
      stats[row.type][row.quality] = {
        count: parseInt(row.count),
        totalSize: parseInt(row.total_size),
        averageSize: parseFloat(row.average_size),
      };
    });

    res.json({
      success: true,
      data: {
        stats,
        totalAssets: result.rows.reduce(
          (sum, row) => sum + parseInt(row.count),
          0
        ),
        totalSize: result.rows.reduce(
          (sum, row) => sum + parseInt(row.total_size),
          0
        ),
      },
    });
  } catch (error) {
    console.error("Error fetching asset stats:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
