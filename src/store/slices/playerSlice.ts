import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { Player, Skin, Purchase } from "@/types";

interface PlayerState {
  currentPlayer: Player | null;
  isAuthenticated: boolean;
  skins: Skin[];
  purchases: Purchase[];
  isLoading: boolean;
  error: string | null;
}

const initialState: PlayerState = {
  currentPlayer: null,
  isAuthenticated: false,
  skins: [],
  purchases: [],
  isLoading: false,
  error: null,
};

const playerSlice = createSlice({
  name: "player",
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
    loginSuccess: (state, action: PayloadAction<Player>) => {
      state.currentPlayer = action.payload;
      state.isAuthenticated = true;
      state.error = null;
    },
    logout: (state) => {
      state.currentPlayer = null;
      state.isAuthenticated = false;
      state.skins = [];
      state.purchases = [];
      state.error = null;
    },
    updatePlayer: (state, action: PayloadAction<Partial<Player>>) => {
      if (state.currentPlayer) {
        state.currentPlayer = { ...state.currentPlayer, ...action.payload };
      }
    },
    setSkins: (state, action: PayloadAction<Skin[]>) => {
      state.skins = action.payload;
    },
    unlockSkin: (state, action: PayloadAction<string>) => {
      const skin = state.skins.find((s) => s.id === action.payload);
      if (skin) {
        skin.isUnlocked = true;
      }
    },
    setCurrentSkin: (state, action: PayloadAction<string>) => {
      if (state.currentPlayer) {
        state.currentPlayer.currentSkin = action.payload;
      }
    },
    addPurchase: (state, action: PayloadAction<Purchase>) => {
      state.purchases.push(action.payload);
    },
    updatePurchase: (
      state,
      action: PayloadAction<{ id: string; status: Purchase["status"] }>
    ) => {
      const purchase = state.purchases.find((p) => p.id === action.payload.id);
      if (purchase) {
        purchase.status = action.payload.status;
      }
    },
    syncPlayerData: (state, action: PayloadAction<Player>) => {
      state.currentPlayer = action.payload;
    },
  },
});

export const {
  setLoading,
  setError,
  loginSuccess,
  logout,
  updatePlayer,
  setSkins,
  unlockSkin,
  setCurrentSkin,
  addPurchase,
  updatePurchase,
  syncPlayerData,
} = playerSlice.actions;

export default playerSlice.reducer;
