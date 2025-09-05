import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { GameSettings } from "@/types";

const initialState: GameSettings = {
  soundEnabled: true,
  musicEnabled: true,
  vibrationEnabled: true,
  graphicsQuality: "medium",
  controlsSensitivity: 0.5,
};

const settingsSlice = createSlice({
  name: "settings",
  initialState,
  reducers: {
    updateSettings: (state, action: PayloadAction<Partial<GameSettings>>) => {
      Object.assign(state, action.payload);
    },
    toggleSound: (state) => {
      state.soundEnabled = !state.soundEnabled;
    },
    toggleMusic: (state) => {
      state.musicEnabled = !state.musicEnabled;
    },
    toggleVibration: (state) => {
      state.vibrationEnabled = !state.vibrationEnabled;
    },
    setGraphicsQuality: (
      state,
      action: PayloadAction<GameSettings["graphicsQuality"]>
    ) => {
      state.graphicsQuality = action.payload;
    },
    setControlsSensitivity: (state, action: PayloadAction<number>) => {
      state.controlsSensitivity = Math.max(0, Math.min(1, action.payload));
    },
    resetSettings: () => initialState,
  },
});

export const {
  updateSettings,
  toggleSound,
  toggleMusic,
  toggleVibration,
  setGraphicsQuality,
  setControlsSensitivity,
  resetSettings,
} = settingsSlice.actions;

export default settingsSlice.reducer;
