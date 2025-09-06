import React, { useEffect, useRef, useState } from "react";
import {
  View,
  StyleSheet,
  TouchableOpacity,
  Text,
  Alert,
  BackHandler,
} from "react-native";
import { useDispatch, useSelector } from "react-redux";
import { StackNavigationProp } from "@react-navigation/stack";
import { RootStackParamList } from "@/types/navigation";
import { RootState } from "@/store";
import {
  pauseGame,
  resumeGame,
  endGame,
  updateScore,
  updateDistance,
} from "@/store/slices/gameSlice";
import { adsService } from "@/services/adsService";
import GameRenderer2D, { GameRenderer2DRef } from "@/components/GameRenderer2D";

type GameScreenNavigationProp = StackNavigationProp<RootStackParamList, "Game">;

interface Props {
  navigation: GameScreenNavigationProp;
}

const GameScreen: React.FC<Props> = ({ navigation }) => {
  const dispatch = useDispatch();
  const { isRunning, isPaused, score, distance, playerHealth } = useSelector(
    (state: RootState) => state.game
  );
  const gameRendererRef = useRef<GameRenderer2DRef>(null);
  const [gameStarted, setGameStarted] = useState(false);

  useEffect(() => {
    // Обработка кнопки "Назад" на Android
    const backHandler = BackHandler.addEventListener(
      "hardwareBackPress",
      () => {
        if (isRunning && !isPaused) {
          handlePause();
          return true;
        }
        return false;
      }
    );

    return () => backHandler.remove();
  }, [isRunning, isPaused]);

  useEffect(() => {
    if (isRunning && !gameStarted) {
      setGameStarted(true);
    }
  }, [isRunning, gameStarted]);

  const handlePause = () => {
    dispatch(pauseGame());
    if (gameRendererRef.current) {
      gameRendererRef.current.pause();
    }
  };

  const handleResume = () => {
    dispatch(resumeGame());
    if (gameRendererRef.current) {
      gameRendererRef.current.resume();
    }
  };

  const handleGameOver = async () => {
    dispatch(endGame());

    // Показываем рекламу после окончания игры
    try {
      const adShown = await adsService.showInterstitialAd();
      if (adShown) {
        console.log("Interstitial ad shown after game over");
      }
    } catch (error) {
      console.error("Failed to show ad after game over:", error);
    }

    // Показываем диалог с результатами
    Alert.alert(
      "Игра окончена!",
      `Ваш счет: ${score.toLocaleString()}\nДистанция: ${distance.toFixed(0)}м`,
      [
        {
          text: "Играть снова",
          onPress: () => {
            setGameStarted(false);
            // Здесь можно перезапустить игру
          },
        },
        {
          text: "В главное меню",
          onPress: () => navigation.goBack(),
        },
      ]
    );
  };

  const handleScoreUpdate = (newScore: number) => {
    dispatch(updateScore(newScore));
  };

  const handleDistanceUpdate = (newDistance: number) => {
    dispatch(updateDistance(newDistance));
  };

  const handleHealthUpdate = (newHealth: number) => {
    if (newHealth <= 0) {
      handleGameOver();
    }
  };

  if (!isRunning) {
    return (
      <View style={styles.container}>
        <Text style={styles.message}>Игра не запущена</Text>
        <TouchableOpacity
          style={styles.button}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.buttonText}>Вернуться в меню</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* 2D игровой движок */}
      <GameRenderer2D
        ref={gameRendererRef}
        onScoreUpdate={handleScoreUpdate}
        onDistanceUpdate={handleDistanceUpdate}
        onHealthUpdate={handleHealthUpdate}
        onGameOver={handleGameOver}
        isPaused={isPaused}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "transparent",
  },
  message: {
    color: "#fff",
    fontSize: 18,
    textAlign: "center",
    marginTop: 100,
  },
  button: {
    backgroundColor: "#007AFF",
    padding: 16,
    borderRadius: 8,
    margin: 20,
    alignItems: "center",
  },
  buttonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
  ui: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    zIndex: 10,
    paddingTop: 50,
    paddingHorizontal: 20,
  },
  topPanel: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
  },
  scoreContainer: {
    alignItems: "flex-start",
  },
  scoreText: {
    color: "#fff",
    fontSize: 24,
    fontWeight: "bold",
    textShadowColor: "#000",
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
  },
  distanceText: {
    color: "#fff",
    fontSize: 16,
    textShadowColor: "#000",
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
  },
  healthContainer: {
    alignItems: "flex-end",
    minWidth: 100,
  },
  healthBar: {
    width: 100,
    height: 8,
    backgroundColor: "#333",
    borderRadius: 4,
    overflow: "hidden",
    marginBottom: 4,
  },
  healthFill: {
    height: "100%",
    backgroundColor: "#34C759",
    borderRadius: 4,
  },
  healthText: {
    color: "#fff",
    fontSize: 14,
    fontWeight: "bold",
    textShadowColor: "#000",
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
  },
  pauseButton: {
    position: "absolute",
    top: 20,
    right: 20,
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    justifyContent: "center",
    alignItems: "center",
  },
  pauseButtonText: {
    fontSize: 20,
  },
});

export default GameScreen;
