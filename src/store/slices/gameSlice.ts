import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { GameState, Obstacle, PowerUp } from "@/types";

const initialState: GameState = {
  score: 0,
  distance: 0,
  coins: 0,
  isRunning: false,
  isPaused: false,
  currentLevel: 1,
  playerHealth: 100,
  maxHealth: 100,
};

const gameSlice = createSlice({
  name: "game",
  initialState,
  reducers: {
    startGame: (state) => {
      state.isRunning = true;
      state.isPaused = false;
      state.score = 0;
      state.distance = 0;
      state.playerHealth = state.maxHealth;
    },
    pauseGame: (state) => {
      state.isPaused = true;
    },
    resumeGame: (state) => {
      state.isPaused = false;
    },
    endGame: (state) => {
      state.isRunning = false;
      state.isPaused = false;
    },
    updateScore: (state, action: PayloadAction<number>) => {
      state.score += action.payload;
    },
    updateDistance: (state, action: PayloadAction<number>) => {
      state.distance += action.payload;
    },
    addCoins: (state, action: PayloadAction<number>) => {
      state.coins += action.payload;
    },
    spendCoins: (state, action: PayloadAction<number>) => {
      state.coins = Math.max(0, state.coins - action.payload);
    },
    updateHealth: (state, action: PayloadAction<number>) => {
      state.playerHealth = Math.max(
        0,
        Math.min(state.maxHealth, state.playerHealth + action.payload)
      );
    },
    levelUp: (state) => {
      state.currentLevel += 1;
      state.maxHealth = Math.min(200, state.maxHealth + 10);
      state.playerHealth = state.maxHealth;
    },
    resetGame: (state) => {
      return { ...initialState, coins: state.coins };
    },
    setGameState: (state, action: PayloadAction<Partial<GameState>>) => {
      Object.assign(state, action.payload);
    },
  },
});

export const {
  startGame,
  pauseGame,
  resumeGame,
  endGame,
  updateScore,
  updateDistance,
  addCoins,
  spendCoins,
  updateHealth,
  levelUp,
  resetGame,
  setGameState,
} = gameSlice.actions;

export default gameSlice.reducer;
