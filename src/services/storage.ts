import * as SQLite from "expo-sqlite";
import { GameState } from "@/types";

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
      CREATE TABLE IF NOT EXISTS local_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id TEXT NOT NULL,
        score INTEGER DEFAULT 0,
        distance INTEGER DEFAULT 0,
        coins INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        health INTEGER DEFAULT 100,
        last_sync_at INTEGER,
        updated_at INTEGER DEFAULT (strftime('%s', 'now')),
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
      const results = await this.db.getAllAsync(
        `SELECT score, distance, coins, level, health FROM local_progress 
         WHERE player_id = ? ORDER BY updated_at DESC LIMIT 1`,
        [playerId]
      );

      if (results && results.length > 0) {
        const result = results[0] as any;
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

  // Settings Management (упрощенная версия без AsyncStorage)
  async saveSettings(settings: Record<string, any>): Promise<void> {
    // Заглушка - в реальном проекте можно использовать SQLite
    console.log("Settings saved:", settings);
  }

  async loadSettings(): Promise<Record<string, any>> {
    // Заглушка - возвращаем настройки по умолчанию
    return {
      soundEnabled: true,
      musicEnabled: true,
      vibrationEnabled: true,
      graphicsQuality: "medium",
      controlsSensitivity: 1.0,
    };
  }

  // Player Data Management (упрощенная версия)
  async savePlayerData(playerId: string, data: any): Promise<void> {
    console.log("Player data saved:", playerId, data);
  }

  async loadPlayerData(playerId: string): Promise<any | null> {
    return null;
  }

  // Offline Queue Management (упрощенная версия)
  async addToOfflineQueue(action: any): Promise<void> {
    console.log("Action added to offline queue:", action);
  }

  async getOfflineQueue(): Promise<any[]> {
    return [];
  }

  async clearOfflineQueue(): Promise<void> {
    console.log("Offline queue cleared");
  }

  // Cache Management (упрощенная версия)
  async saveCache(
    key: string,
    data: any,
    ttl: number = 3600000
  ): Promise<void> {
    console.log("Cache saved:", key);
  }

  async getCache(key: string): Promise<any | null> {
    return null;
  }

  async clearCache(): Promise<void> {
    console.log("Cache cleared");
  }

  // Utility Methods
  async clearAllData(): Promise<void> {
    try {
      if (this.db) {
        await this.db.execAsync("DELETE FROM local_progress");
      }
    } catch (error) {
      console.error("Failed to clear all data:", error);
    }
  }

  async getStorageSize(): Promise<number> {
    return 0;
  }

  // Leaderboard cache methods
  async cacheLeaderboard(entries: any[], timeRange: string): Promise<void> {
    console.log(
      "Leaderboard cached:",
      entries.length,
      "entries for",
      timeRange
    );
  }

  async getCachedLeaderboard(timeRange: string): Promise<any[]> {
    console.log("Getting cached leaderboard for:", timeRange);
    return [];
  }
}

export default new StorageService();
