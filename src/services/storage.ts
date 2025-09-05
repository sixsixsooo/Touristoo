import * as SQLite from "expo-sqlite";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { GameState, Player, GameSettings, LeaderboardEntry } from "@/types";

class StorageService {
  private db: SQLite.SQLiteDatabase | null = null;

  async initialize(): Promise<void> {
    try {
      this.db = await SQLite.openDatabaseAsync("touristoo_runner.db");
      await this.createTables();
    } catch (error) {
      console.error("Failed to initialize database:", error);
    }
  }

  private async createTables(): Promise<void> {
    if (!this.db) return;

    const createTablesSQL = `
      -- Таблица для локального прогресса игрока
      CREATE TABLE IF NOT EXISTS local_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id TEXT,
        score INTEGER DEFAULT 0,
        distance REAL DEFAULT 0,
        coins INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        health INTEGER DEFAULT 100,
        last_sync_at INTEGER,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER DEFAULT (strftime('%s', 'now'))
      );

      -- Таблица для настроек игры
      CREATE TABLE IF NOT EXISTS game_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        updated_at INTEGER DEFAULT (strftime('%s', 'now'))
      );

      -- Таблица для кэша лидерборда
      CREATE TABLE IF NOT EXISTS leaderboard_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id TEXT,
        player_name TEXT,
        score INTEGER,
        rank INTEGER,
        avatar TEXT,
        is_guest INTEGER,
        time_range TEXT,
        cached_at INTEGER DEFAULT (strftime('%s', 'now'))
      );

      -- Таблица для офлайн достижений
      CREATE TABLE IF NOT EXISTS achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id TEXT,
        achievement_id TEXT,
        unlocked_at INTEGER DEFAULT (strftime('%s', 'now')),
        synced INTEGER DEFAULT 0
      );

      -- Таблица для офлайн покупок
      CREATE TABLE IF NOT EXISTS offline_purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id TEXT UNIQUE,
        player_id TEXT,
        item_type TEXT,
        item_id TEXT,
        amount INTEGER,
        price REAL,
        currency TEXT,
        status TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        synced INTEGER DEFAULT 0
      );
    `;

    await this.db.execAsync(createTablesSQL);
  }

  // Game State Management
  async saveGameState(playerId: string, gameState: GameState): Promise<void> {
    if (!this.db) return;

    try {
      await this.db.runAsync(
        `INSERT OR REPLACE INTO local_progress 
         (player_id, score, distance, coins, level, health, last_sync_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, strftime('%s', 'now'))`,
        [
          playerId,
          gameState.score,
          gameState.distance,
          gameState.coins,
          gameState.currentLevel,
          gameState.playerHealth,
          Date.now(),
        ]
      );
    } catch (error) {
      console.error("Failed to save game state:", error);
    }
  }

  async loadGameState(playerId: string): Promise<GameState | null> {
    if (!this.db) return null;

    try {
      const result = await this.db.getFirstAsync(
        `SELECT score, distance, coins, level, health FROM local_progress 
         WHERE player_id = ? ORDER BY updated_at DESC LIMIT 1`,
        [playerId]
      );

      if (result) {
        return {
          score: result.score || 0,
          distance: result.distance || 0,
          coins: result.coins || 0,
          currentLevel: result.level || 1,
          playerHealth: result.health || 100,
          maxHealth: 100,
          isRunning: false,
          isPaused: false,
        };
      }
    } catch (error) {
      console.error("Failed to load game state:", error);
    }

    return null;
  }

  // Settings Management
  async saveSettings(settings: GameSettings): Promise<void> {
    if (!this.db) return;

    try {
      const settingsArray = Object.entries(settings);

      for (const [key, value] of settingsArray) {
        await this.db.runAsync(
          `INSERT OR REPLACE INTO game_settings (key, value, updated_at) 
           VALUES (?, ?, strftime('%s', 'now'))`,
          [key, JSON.stringify(value)]
        );
      }
    } catch (error) {
      console.error("Failed to save settings:", error);
    }
  }

  async loadSettings(): Promise<GameSettings> {
    if (!this.db) {
      return {
        soundEnabled: true,
        musicEnabled: true,
        vibrationEnabled: true,
        graphicsQuality: "medium",
        controlsSensitivity: 0.5,
      };
    }

    try {
      const results = await this.db.getAllAsync(
        "SELECT key, value FROM game_settings"
      );

      const settings: Partial<GameSettings> = {};

      for (const row of results) {
        try {
          settings[row.key as keyof GameSettings] = JSON.parse(row.value);
        } catch (parseError) {
          console.warn(`Failed to parse setting ${row.key}:`, parseError);
        }
      }

      return {
        soundEnabled: settings.soundEnabled ?? true,
        musicEnabled: settings.musicEnabled ?? true,
        vibrationEnabled: settings.vibrationEnabled ?? true,
        graphicsQuality: settings.graphicsQuality ?? "medium",
        controlsSensitivity: settings.controlsSensitivity ?? 0.5,
      };
    } catch (error) {
      console.error("Failed to load settings:", error);
      return {
        soundEnabled: true,
        musicEnabled: true,
        vibrationEnabled: true,
        graphicsQuality: "medium",
        controlsSensitivity: 0.5,
      };
    }
  }

  // Leaderboard Cache
  async cacheLeaderboard(
    entries: LeaderboardEntry[],
    timeRange: string = "all"
  ): Promise<void> {
    if (!this.db) return;

    try {
      // Очищаем старый кэш
      await this.db.runAsync(
        "DELETE FROM leaderboard_cache WHERE time_range = ?",
        [timeRange]
      );

      // Сохраняем новый кэш
      for (const entry of entries) {
        await this.db.runAsync(
          `INSERT INTO leaderboard_cache 
           (player_id, player_name, score, rank, avatar, is_guest, time_range)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            entry.id,
            entry.playerName,
            entry.score,
            entry.rank,
            entry.avatar || null,
            entry.isGuest ? 1 : 0,
            timeRange,
          ]
        );
      }
    } catch (error) {
      console.error("Failed to cache leaderboard:", error);
    }
  }

  async getCachedLeaderboard(
    timeRange: string = "all"
  ): Promise<LeaderboardEntry[]> {
    if (!this.db) return [];

    try {
      const results = await this.db.getAllAsync(
        `SELECT player_id as id, player_name as playerName, score, rank, avatar, is_guest as isGuest
         FROM leaderboard_cache 
         WHERE time_range = ? 
         ORDER BY rank ASC`,
        [timeRange]
      );

      return results.map((row) => ({
        id: row.id,
        playerName: row.playerName,
        score: row.score,
        rank: row.rank,
        avatar: row.avatar,
        isGuest: Boolean(row.isGuest),
      }));
    } catch (error) {
      console.error("Failed to get cached leaderboard:", error);
      return [];
    }
  }

  // AsyncStorage для простых данных
  async saveToAsyncStorage(key: string, value: any): Promise<void> {
    try {
      await AsyncStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(`Failed to save to AsyncStorage (${key}):`, error);
    }
  }

  async loadFromAsyncStorage<T>(key: string, defaultValue: T): Promise<T> {
    try {
      const value = await AsyncStorage.getItem(key);
      return value ? JSON.parse(value) : defaultValue;
    } catch (error) {
      console.error(`Failed to load from AsyncStorage (${key}):`, error);
      return defaultValue;
    }
  }

  // Очистка данных
  async clearAllData(): Promise<void> {
    if (!this.db) return;

    try {
      await this.db.execAsync(`
        DELETE FROM local_progress;
        DELETE FROM game_settings;
        DELETE FROM leaderboard_cache;
        DELETE FROM achievements;
        DELETE FROM offline_purchases;
      `);

      await AsyncStorage.clear();
    } catch (error) {
      console.error("Failed to clear all data:", error);
    }
  }

  // Синхронизация данных
  async getUnsyncedData(): Promise<{
    achievements: any[];
    purchases: any[];
  }> {
    if (!this.db) return { achievements: [], purchases: [] };

    try {
      const achievements = await this.db.getAllAsync(
        "SELECT * FROM achievements WHERE synced = 0"
      );

      const purchases = await this.db.getAllAsync(
        "SELECT * FROM offline_purchases WHERE synced = 0"
      );

      return { achievements, purchases };
    } catch (error) {
      console.error("Failed to get unsynced data:", error);
      return { achievements: [], purchases: [] };
    }
  }

  async markAsSynced(table: string, ids: string[]): Promise<void> {
    if (!this.db || ids.length === 0) return;

    try {
      const placeholders = ids.map(() => "?").join(",");
      await this.db.runAsync(
        `UPDATE ${table} SET synced = 1 WHERE id IN (${placeholders})`,
        ids
      );
    } catch (error) {
      console.error(`Failed to mark ${table} as synced:`, error);
    }
  }
}

export const storageService = new StorageService();
export default storageService;
