import React, { useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
  Alert,
} from "react-native";
import { useDispatch, useSelector } from "react-redux";
import { StackNavigationProp } from "@react-navigation/stack";
import { RootStackParamList } from "@/types/navigation";
import { RootState } from "@/store";
import { startGame } from "@/store/slices/gameSlice";
import { adsService } from "@/services/adsService";

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, "Main">;

interface Props {
  navigation: HomeScreenNavigationProp;
}

const HomeScreen: React.FC<Props> = ({ navigation }) => {
  const dispatch = useDispatch();
  const { currentPlayer, isAuthenticated } = useSelector(
    (state: RootState) => state.player
  );
  const { score, coins, currentLevel } = useSelector(
    (state: RootState) => state.game
  );

  useEffect(() => {
    // Показываем баннерную рекламу на главном экране
    adsService.showBannerAd();
  }, []);

  const handleStartGame = async () => {
    try {
      // Проверяем готовность межстраничной рекламы
      const isAdReady = await adsService.isInterstitialAdReady();

      if (isAdReady) {
        // Показываем рекламу перед началом игры
        const adShown = await adsService.showInterstitialAd();
        if (adShown) {
          console.log("Interstitial ad shown before game start");
        }
      }

      dispatch(startGame());
      navigation.navigate("Game");
    } catch (error) {
      console.error("Failed to start game:", error);
      Alert.alert("Ошибка", "Не удалось запустить игру");
    }
  };

  const handleShowRewardedAd = async () => {
    try {
      const result = await adsService.showRewardedAd();
      if (result.success && result.reward) {
        Alert.alert(
          "Награда получена!",
          `Вы получили ${result.reward.amount} монет!`,
          [{ text: "OK" }]
        );
        // Здесь можно добавить логику начисления награды
      }
    } catch (error) {
      console.error("Failed to show rewarded ad:", error);
      Alert.alert("Ошибка", "Не удалось показать рекламу");
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        {/* Заголовок */}
        <View style={styles.header}>
          <Text style={styles.title}>Touristoo Runner</Text>
          <Text style={styles.subtitle}>Беги, собирай монеты, выживай!</Text>
        </View>

        {/* Статистика игрока */}
        <View style={styles.statsContainer}>
          <View style={styles.statItem}>
            <Text style={styles.statValue}>{score.toLocaleString()}</Text>
            <Text style={styles.statLabel}>Лучший счет</Text>
          </View>
          <View style={styles.statItem}>
            <Text style={styles.statValue}>{coins}</Text>
            <Text style={styles.statLabel}>Монеты</Text>
          </View>
          <View style={styles.statItem}>
            <Text style={styles.statValue}>{currentLevel}</Text>
            <Text style={styles.statLabel}>Уровень</Text>
          </View>
        </View>

        {/* Информация о игроке */}
        {isAuthenticated && currentPlayer && (
          <View style={styles.playerInfo}>
            <Text style={styles.playerName}>Привет, {currentPlayer.name}!</Text>
            {currentPlayer.isGuest && (
              <Text style={styles.guestWarning}>
                Вы играете как гость. Войдите в аккаунт для синхронизации
                прогресса.
              </Text>
            )}
          </View>
        )}

        {/* Кнопки действий */}
        <View style={styles.actionsContainer}>
          <TouchableOpacity
            style={styles.primaryButton}
            onPress={handleStartGame}
            activeOpacity={0.8}
          >
            <Text style={styles.primaryButtonText}>ИГРАТЬ</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.secondaryButton}
            onPress={handleShowRewardedAd}
            activeOpacity={0.8}
          >
            <Text style={styles.secondaryButtonText}>
              Смотреть рекламу за монеты
            </Text>
          </TouchableOpacity>

          {!isAuthenticated && (
            <TouchableOpacity
              style={styles.linkButton}
              onPress={() => navigation.navigate("Profile")}
              activeOpacity={0.8}
            >
              <Text style={styles.linkButtonText}>Войти в аккаунт</Text>
            </TouchableOpacity>
          )}
        </View>

        {/* Быстрые действия */}
        <View style={styles.quickActions}>
          <TouchableOpacity
            style={styles.quickActionButton}
            onPress={() => navigation.navigate("Leaderboard")}
            activeOpacity={0.8}
          >
            <Text style={styles.quickActionText}>🏆 Рейтинг</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.quickActionButton}
            onPress={() => navigation.navigate("Shop")}
            activeOpacity={0.8}
          >
            <Text style={styles.quickActionText}>🛒 Магазин</Text>
          </TouchableOpacity>
        </View>
      </View>
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
    padding: 20,
    justifyContent: "center",
  },
  header: {
    alignItems: "center",
    marginBottom: 40,
  },
  title: {
    fontSize: 32,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: "#666",
    textAlign: "center",
  },
  statsContainer: {
    flexDirection: "row",
    justifyContent: "space-around",
    marginBottom: 30,
    backgroundColor: "#fff",
    borderRadius: 12,
    padding: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statItem: {
    alignItems: "center",
  },
  statValue: {
    fontSize: 24,
    fontWeight: "bold",
    color: "#007AFF",
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 12,
    color: "#666",
  },
  playerInfo: {
    backgroundColor: "#fff",
    borderRadius: 12,
    padding: 16,
    marginBottom: 30,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  playerName: {
    fontSize: 18,
    fontWeight: "600",
    color: "#333",
    marginBottom: 8,
  },
  guestWarning: {
    fontSize: 14,
    color: "#ff6b6b",
  },
  actionsContainer: {
    marginBottom: 30,
  },
  primaryButton: {
    backgroundColor: "#007AFF",
    borderRadius: 12,
    padding: 16,
    alignItems: "center",
    marginBottom: 12,
    shadowColor: "#007AFF",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 5,
  },
  primaryButtonText: {
    color: "#fff",
    fontSize: 18,
    fontWeight: "bold",
  },
  secondaryButton: {
    backgroundColor: "#34C759",
    borderRadius: 12,
    padding: 16,
    alignItems: "center",
    marginBottom: 12,
  },
  secondaryButtonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "600",
  },
  linkButton: {
    alignItems: "center",
    padding: 12,
  },
  linkButtonText: {
    color: "#007AFF",
    fontSize: 16,
    fontWeight: "500",
  },
  quickActions: {
    flexDirection: "row",
    justifyContent: "space-around",
  },
  quickActionButton: {
    backgroundColor: "#fff",
    borderRadius: 12,
    padding: 16,
    flex: 1,
    marginHorizontal: 8,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  quickActionText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#333",
  },
});

export default HomeScreen;
