import React, { useEffect } from "react";
import { Provider } from "react-redux";
import { StatusBar } from "expo-status-bar";
import { store } from "@/store";
import AppNavigator from "@/navigation/AppNavigator";
import { storageService } from "@/services/storage";
import { adsService } from "@/services/adsService";

// Конфигурация рекламы
const AD_CONFIG = {
  bannerAdUnitId: "your-banner-ad-unit-id",
  interstitialAdUnitId: "your-interstitial-ad-unit-id",
  rewardedAdUnitId: "your-rewarded-ad-unit-id",
  isEnabled: __DEV__ ? false : true, // Отключаем рекламу в режиме разработки
};

export default function App() {
  useEffect(() => {
    initializeApp();
  }, []);

  const initializeApp = async () => {
    try {
      // Инициализируем локальное хранилище
      await storageService.initialize();

      // Инициализируем сервис рекламы
      await adsService.initialize(AD_CONFIG);

      console.log("App initialized successfully");
    } catch (error) {
      console.error("Failed to initialize app:", error);
    }
  };

  return (
    <Provider store={store}>
      <StatusBar style="auto" />
      <AppNavigator />
    </Provider>
  );
}
