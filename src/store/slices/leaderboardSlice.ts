import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { LeaderboardEntry } from "@/types";

interface LeaderboardState {
  entries: LeaderboardEntry[];
  currentPlayerRank: number | null;
  isLoading: boolean;
  error: string | null;
  lastUpdated: Date | null;
}

const initialState: LeaderboardState = {
  entries: [],
  currentPlayerRank: null,
  isLoading: false,
  error: null,
  lastUpdated: null,
};

const leaderboardSlice = createSlice({
  name: "leaderboard",
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
    setLeaderboard: (state, action: PayloadAction<LeaderboardEntry[]>) => {
      state.entries = action.payload;
      state.lastUpdated = new Date();
      state.error = null;
    },
    setCurrentPlayerRank: (state, action: PayloadAction<number | null>) => {
      state.currentPlayerRank = action.payload;
    },
    updatePlayerScore: (
      state,
      action: PayloadAction<{ playerId: string; score: number }>
    ) => {
      const entry = state.entries.find((e) => e.id === action.payload.playerId);
      if (entry) {
        entry.score = action.payload.score;
        // Пересортировка может потребоваться на бэкенде
      }
    },
    clearLeaderboard: (state) => {
      state.entries = [];
      state.currentPlayerRank = null;
      state.lastUpdated = null;
    },
  },
});

export const {
  setLoading,
  setError,
  setLeaderboard,
  setCurrentPlayerRank,
  updatePlayerScore,
  clearLeaderboard,
} = leaderboardSlice.actions;

export default leaderboardSlice.reducer;
