import { configureStore } from "@reduxjs/toolkit";
import gameReducer from "./slices/gameSlice";
import playerReducer from "./slices/playerSlice";
import settingsReducer from "./slices/settingsSlice";
import leaderboardReducer from "./slices/leaderboardSlice";

export const store = configureStore({
  reducer: {
    game: gameReducer,
    player: playerReducer,
    settings: settingsReducer,
    leaderboard: leaderboardReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ["persist/PERSIST"],
      },
    }),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
