// Основные типы для игры

export interface GameState {
  score: number;
  distance: number;
  coins: number;
  isRunning: boolean;
  isPaused: boolean;
  currentLevel: number;
  playerHealth: number;
  maxHealth: number;
}

export interface Player {
  id: string;
  name: string;
  email?: string;
  avatar?: string;
  totalScore: number;
  level: number;
  coins: number;
  skins: string[];
  currentSkin: string;
  isGuest: boolean;
  lastSyncAt?: Date;
}

export interface LeaderboardEntry {
  id: string;
  playerName: string;
  score: number;
  rank: number;
  avatar?: string;
  isGuest: boolean;
}

export interface GameSettings {
  soundEnabled: boolean;
  musicEnabled: boolean;
  vibrationEnabled: boolean;
  graphicsQuality: "low" | "medium" | "high";
  controlsSensitivity: number;
}

export interface Obstacle {
  id: string;
  type: "jump" | "slide" | "duck";
  position: { x: number; y: number; z: number };
  speed: number;
  isActive: boolean;
}

export interface PowerUp {
  id: string;
  type: "coin" | "health" | "speed" | "shield";
  position: { x: number; y: number; z: number };
  value: number;
  isActive: boolean;
}

export interface Skin {
  id: string;
  name: string;
  description: string;
  price: number;
  isUnlocked: boolean;
  modelPath: string;
  texturePath: string;
  rarity: "common" | "rare" | "epic" | "legendary";
}

export interface Purchase {
  id: string;
  playerId: string;
  itemType: "skin" | "coin_pack" | "booster";
  itemId: string;
  amount: number;
  price: number;
  currency: "rub" | "coins";
  status: "pending" | "completed" | "failed";
  createdAt: Date;
}

export interface AdConfig {
  bannerAdUnitId: string;
  interstitialAdUnitId: string;
  rewardedAdUnitId: string;
  isEnabled: boolean;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface LoginRequest {
  email?: string;
  password?: string;
  name?: string;
  yandexId?: string;
  isGuest?: boolean;
}

export interface LoginResponse {
  player: Player;
  token: string;
  refreshToken: string;
}

export interface LeaderboardRequest {
  limit?: number;
  offset?: number;
  timeRange?: "daily" | "weekly" | "monthly" | "all";
}

export interface SyncRequest {
  playerId: string;
  gameState: GameState;
  achievements: string[];
  purchases: Purchase[];
}

export interface SyncResponse {
  success: boolean;
  serverState?: GameState;
  newAchievements?: string[];
  conflicts?: {
    field: string;
    localValue: any;
    serverValue: any;
  }[];
}
