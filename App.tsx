import React, { useEffect } from "react";
import { Provider } from "react-redux";
import { StatusBar } from "expo-status-bar";
import { store } from "@/store";
import AppNavigator from "@/navigation/AppNavigator";
import storageService from "@/services/storage";

export default function App() {
  useEffect(() => {
    initializeApp();
  }, []);

  const initializeApp = async () => {
    try {
      // Инициализируем локальное хранилище
      await storageService.initialize();

      console.log("Приложение успешно инициализировано");
    } catch (error) {
      console.error("Ошибка инициализации приложения:", error);
    }
  };

  return (
    <Provider store={store}>
      <StatusBar style="auto" />
      <AppNavigator />
    </Provider>
  );
}
