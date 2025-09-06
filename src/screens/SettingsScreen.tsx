import React, { useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  Switch,
  TouchableOpacity,
  SafeAreaView,
  Alert,
  ScrollView,
} from "react-native";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "@/store";
import { GameSettings } from "@/types";
import storageService from "@/services/storage";

const SettingsScreen: React.FC = () => {
  const dispatch = useDispatch();
  const settings = useSelector((state: RootState) => state.settings);
  const { currentPlayer, isAuthenticated } = useSelector(
    (state: RootState) => state.player
  );

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    try {
      const savedSettings = await storageService.loadSettings();
      dispatch({ type: "settings/updateSettings", payload: savedSettings });
    } catch (error) {
      console.error("Failed to load settings:", error);
    }
  };

  const saveSettings = async (newSettings: Partial<GameSettings>) => {
    try {
      dispatch({ type: "settings/updateSettings", payload: newSettings });
      const updatedSettings = { ...settings, ...newSettings };
      await storageService.saveSettings(updatedSettings);
    } catch (error) {
      console.error("Failed to save settings:", error);
      Alert.alert("Ошибка", "Не удалось сохранить настройки");
    }
  };

  const handleToggleSound = () => {
    saveSettings({ soundEnabled: !settings.soundEnabled });
  };

  const handleToggleMusic = () => {
    saveSettings({ musicEnabled: !settings.musicEnabled });
  };

  const handleToggleVibration = () => {
    saveSettings({ vibrationEnabled: !settings.vibrationEnabled });
  };

  const handleGraphicsQualityChange = (
    quality: GameSettings["graphicsQuality"]
  ) => {
    saveSettings({ graphicsQuality: quality });
  };

  const handleControlsSensitivityChange = (sensitivity: number) => {
    saveSettings({ controlsSensitivity: sensitivity });
  };

  const handleResetSettings = () => {
    Alert.alert(
      "Сброс настроек",
      "Вы уверены, что хотите сбросить все настройки к значениям по умолчанию?",
      [
        { text: "Отмена", style: "cancel" },
        {
          text: "Сбросить",
          style: "destructive",
          onPress: () => {
            dispatch({ type: "settings/resetSettings" });
            saveSettings({
              soundEnabled: true,
              musicEnabled: true,
              vibrationEnabled: true,
              graphicsQuality: "medium",
              controlsSensitivity: 0.5,
            });
          },
        },
      ]
    );
  };

  const handleClearCache = () => {
    Alert.alert(
      "Очистка кэша",
      "Это действие удалит все кэшированные данные. Продолжить?",
      [
        { text: "Отмена", style: "cancel" },
        {
          text: "Очистить",
          style: "destructive",
          onPress: async () => {
            try {
              await storageService.clearAllData();
              Alert.alert("Успех", "Кэш очищен");
            } catch (error) {
              Alert.alert("Ошибка", "Не удалось очистить кэш");
            }
          },
        },
      ]
    );
  };

  const renderSettingItem = (
    title: string,
    description: string,
    rightComponent: React.ReactNode
  ) => (
    <View style={styles.settingItem}>
      <View style={styles.settingInfo}>
        <Text style={styles.settingTitle}>{title}</Text>
        <Text style={styles.settingDescription}>{description}</Text>
      </View>
      {rightComponent}
    </View>
  );

  const renderGraphicsQualitySelector = () => (
    <View style={styles.qualitySelector}>
      {(["low", "medium", "high"] as const).map((quality) => (
        <TouchableOpacity
          key={quality}
          style={[
            styles.qualityButton,
            settings.graphicsQuality === quality && styles.activeQualityButton,
          ]}
          onPress={() => handleGraphicsQualityChange(quality)}
        >
          <Text
            style={[
              styles.qualityButtonText,
              settings.graphicsQuality === quality &&
                styles.activeQualityButtonText,
            ]}
          >
            {quality === "low" && "Низкое"}
            {quality === "medium" && "Среднее"}
            {quality === "high" && "Высокое"}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );

  const renderSensitivitySlider = () => (
    <View style={styles.sensitivityContainer}>
      <View style={styles.sensitivityLabels}>
        <Text style={styles.sensitivityLabel}>Медленно</Text>
        <Text style={styles.sensitivityLabel}>Быстро</Text>
      </View>
      <View style={styles.sensitivitySlider}>
        {[0, 0.25, 0.5, 0.75, 1].map((value) => (
          <TouchableOpacity
            key={value}
            style={[
              styles.sensitivityButton,
              Math.abs(settings.controlsSensitivity - value) < 0.1 &&
                styles.activeSensitivityButton,
            ]}
            onPress={() => handleControlsSensitivityChange(value)}
          />
        ))}
      </View>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <Text style={styles.title}>Настройки</Text>
          {isAuthenticated && currentPlayer && (
            <Text style={styles.subtitle}>
              {currentPlayer.isGuest ? "Гостевой аккаунт" : currentPlayer.name}
            </Text>
          )}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Звук и музыка</Text>

          {renderSettingItem(
            "Звуковые эффекты",
            "Включить звуки в игре",
            <Switch
              value={settings.soundEnabled}
              onValueChange={handleToggleSound}
              trackColor={{ false: "#E0E0E0", true: "#007AFF" }}
              thumbColor={settings.soundEnabled ? "#fff" : "#f4f3f4"}
            />
          )}

          {renderSettingItem(
            "Фоновая музыка",
            "Включить музыку в меню и игре",
            <Switch
              value={settings.musicEnabled}
              onValueChange={handleToggleMusic}
              trackColor={{ false: "#E0E0E0", true: "#007AFF" }}
              thumbColor={settings.musicEnabled ? "#fff" : "#f4f3f4"}
            />
          )}

          {renderSettingItem(
            "Вибрация",
            "Вибрация при касаниях и событиях",
            <Switch
              value={settings.vibrationEnabled}
              onValueChange={handleToggleVibration}
              trackColor={{ false: "#E0E0E0", true: "#007AFF" }}
              thumbColor={settings.vibrationEnabled ? "#fff" : "#f4f3f4"}
            />
          )}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Графика</Text>

          {renderSettingItem(
            "Качество графики",
            "Влияет на производительность и качество",
            renderGraphicsQualitySelector()
          )}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Управление</Text>

          {renderSettingItem(
            "Чувствительность",
            "Настройка чувствительности касаний",
            renderSensitivitySlider()
          )}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Данные</Text>

          <TouchableOpacity
            style={styles.actionButton}
            onPress={handleClearCache}
          >
            <Text style={styles.actionButtonText}>Очистить кэш</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.actionButton, styles.dangerButton]}
            onPress={handleResetSettings}
          >
            <Text style={[styles.actionButtonText, styles.dangerButtonText]}>
              Сбросить настройки
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.footer}>
          <Text style={styles.footerText}>Touristoo Runner v1.0.0</Text>
          <Text style={styles.footerText}>© 2024 Touristoo Games</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f0f0f0",
  },
  content: {
    flex: 1,
  },
  header: {
    backgroundColor: "#fff",
    padding: 20,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    color: "#333",
  },
  subtitle: {
    fontSize: 16,
    color: "#666",
    marginTop: 4,
  },
  section: {
    backgroundColor: "#fff",
    marginTop: 10,
    paddingVertical: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#333",
    marginHorizontal: 20,
    marginBottom: 16,
  },
  settingItem: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: "#f0f0f0",
  },
  settingInfo: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: "500",
    color: "#333",
    marginBottom: 4,
  },
  settingDescription: {
    fontSize: 14,
    color: "#666",
  },
  qualitySelector: {
    flexDirection: "row",
    backgroundColor: "#f0f0f0",
    borderRadius: 8,
    padding: 4,
  },
  qualityButton: {
    flex: 1,
    paddingVertical: 8,
    paddingHorizontal: 12,
    alignItems: "center",
    borderRadius: 6,
  },
  activeQualityButton: {
    backgroundColor: "#007AFF",
  },
  qualityButtonText: {
    fontSize: 14,
    fontWeight: "500",
    color: "#666",
  },
  activeQualityButtonText: {
    color: "#fff",
  },
  sensitivityContainer: {
    alignItems: "center",
  },
  sensitivityLabels: {
    flexDirection: "row",
    justifyContent: "space-between",
    width: "100%",
    marginBottom: 8,
  },
  sensitivityLabel: {
    fontSize: 12,
    color: "#666",
  },
  sensitivitySlider: {
    flexDirection: "row",
    alignItems: "center",
  },
  sensitivityButton: {
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: "#E0E0E0",
    marginHorizontal: 8,
  },
  activeSensitivityButton: {
    backgroundColor: "#007AFF",
  },
  actionButton: {
    backgroundColor: "#fff",
    marginHorizontal: 20,
    marginVertical: 8,
    padding: 16,
    borderRadius: 12,
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#E0E0E0",
  },
  actionButtonText: {
    fontSize: 16,
    fontWeight: "500",
    color: "#333",
  },
  dangerButton: {
    borderColor: "#ff6b6b",
  },
  dangerButtonText: {
    color: "#ff6b6b",
  },
  footer: {
    alignItems: "center",
    padding: 20,
    marginTop: 20,
  },
  footerText: {
    fontSize: 12,
    color: "#999",
    marginBottom: 4,
  },
});

export default SettingsScreen;
