const { Pool } = require("pg");

// Database configuration
const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || "touristoo_runner",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "password",
  ssl:
    process.env.NODE_ENV === "production"
      ? { rejectUnauthorized: false }
      : false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test database connection
pool.on("connect", () => {
  console.log("Connected to PostgreSQL database");
});

pool.on("error", (err) => {
  console.error("Database connection error:", err);
});

// Initialize database tables
const initializeDatabase = async () => {
  try {
    // Create players table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS players (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        username VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE,
        password_hash VARCHAR(255),
        avatar VARCHAR(500),
        total_score INTEGER DEFAULT 0,
        best_distance INTEGER DEFAULT 0,
        total_coins INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        experience INTEGER DEFAULT 0,
        achievements JSONB DEFAULT '[]'::jsonb,
        settings JSONB DEFAULT '{}'::jsonb,
        skins TEXT[] DEFAULT ARRAY['1'],
        current_skin VARCHAR(50) DEFAULT '1',
        is_guest BOOLEAN DEFAULT FALSE,
        yandex_id VARCHAR(100) UNIQUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        last_login TIMESTAMP WITH TIME ZONE,
        last_sync_at TIMESTAMP WITH TIME ZONE
      )
    `);

    // Create leaderboard table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS leaderboard (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        player_id UUID REFERENCES players(id) ON DELETE CASCADE,
        score INTEGER NOT NULL,
        distance REAL NOT NULL,
        level INTEGER NOT NULL,
        time_range VARCHAR(20) DEFAULT 'all',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(player_id, time_range)
      )
    `);

    // Create achievements table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS achievements (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        player_id UUID REFERENCES players(id) ON DELETE CASCADE,
        achievement_id VARCHAR(50) NOT NULL,
        unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(player_id, achievement_id)
      )
    `);

    // Create purchases table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS purchases (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        player_id UUID REFERENCES players(id) ON DELETE CASCADE,
        item_type VARCHAR(20) NOT NULL,
        item_id VARCHAR(50) NOT NULL,
        amount INTEGER NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        currency VARCHAR(10) NOT NULL,
        status VARCHAR(20) DEFAULT 'pending',
        payment_id VARCHAR(100),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      )
    `);

    // Create game_sessions table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS game_sessions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        player_id UUID REFERENCES players(id) ON DELETE CASCADE,
        score INTEGER NOT NULL,
        distance REAL NOT NULL,
        coins_collected INTEGER DEFAULT 0,
        obstacles_avoided INTEGER DEFAULT 0,
        power_ups_collected INTEGER DEFAULT 0,
        duration_seconds INTEGER NOT NULL,
        level_reached INTEGER NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      )
    `);

    // Create assets table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS assets (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(255) NOT NULL,
        type VARCHAR(50) NOT NULL,
        quality VARCHAR(20) NOT NULL,
        url TEXT NOT NULL,
        size BIGINT DEFAULT 0,
        format VARCHAR(20),
        metadata JSONB,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(name, type, quality)
      )
    `);

    // Create indexes for better performance
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_leaderboard_score ON leaderboard(score DESC);
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_leaderboard_time_range ON leaderboard(time_range);
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_players_email ON players(email);
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_game_sessions_player_id ON game_sessions(player_id);
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_assets_type_quality ON assets(type, quality);
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_assets_name ON assets(name);
    `);

    console.log("Database tables initialized successfully");
  } catch (error) {
    console.error("Failed to initialize database:", error);
    throw error;
  }
};

// Initialize database on startup
initializeDatabase().catch(console.error);

module.exports = { pool, initializeDatabase };
