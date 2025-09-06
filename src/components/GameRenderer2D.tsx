import React, {
  useRef,
  useEffect,
  useState,
  useCallback,
  useImperativeHandle,
  forwardRef,
} from "react";
import { View, StyleSheet, Dimensions, Animated } from "react-native";
import { GameState } from "@/types";

interface GameRenderer2DProps {
  onScoreUpdate: (score: number) => void;
  onDistanceUpdate: (distance: number) => void;
  onHealthUpdate: (health: number) => void;
  onGameOver: () => void;
  isPaused: boolean;
}

export interface GameRenderer2DRef {
  pause: () => void;
  resume: () => void;
  reset: () => void;
  start: () => void;
}

const GameRenderer2D = forwardRef<GameRenderer2DRef, GameRenderer2DProps>(
  (props, ref) => {
    const {
      onScoreUpdate,
      onDistanceUpdate,
      onHealthUpdate,
      onGameOver,
      isPaused,
    } = props;

    const [gameState, setGameState] = useState<GameState>({
      isRunning: false,
      isPaused: false,
      score: 0,
      distance: 0,
      playerHealth: 100,
      playerLane: 1, // 0 = левая, 1 = центр, 2 = правая
      obstacles: [],
      coins: [],
      gameSpeed: 1,
    });

    const gameLoopRef = useRef<number | null>(null);
    const lastTimeRef = useRef<number>(0);
    const playerPositionRef = useRef<Animated.Value>(new Animated.Value(1)); // 0, 1, 2
    const roadOffsetRef = useRef<Animated.Value>(new Animated.Value(0));

    // Игровые объекты
    const obstaclesRef = useRef<
      Array<{
        id: number;
        lane: number;
        y: number;
        type: "barrier" | "cone" | "block";
      }>
    >([]);
    const coinsRef = useRef<
      Array<{
        id: number;
        lane: number;
        y: number;
      }>
    >([]);

    const nextObstacleIdRef = useRef(0);
    const nextCoinIdRef = useRef(0);

    // Создание препятствий
    const createObstacle = useCallback(() => {
      const lane = Math.floor(Math.random() * 3);
      const types: Array<"barrier" | "cone" | "block"> = [
        "barrier",
        "cone",
        "block",
      ];
      const type = types[Math.floor(Math.random() * types.length)];

      const obstacle = {
        id: nextObstacleIdRef.current++,
        lane,
        y: -100,
        type,
      };

      obstaclesRef.current.push(obstacle);
    }, []);

    // Создание монет
    const createCoin = useCallback(() => {
      const lane = Math.floor(Math.random() * 3);

      const coin = {
        id: nextCoinIdRef.current++,
        lane,
        y: -100,
      };

      coinsRef.current.push(coin);
    }, []);

    // Игровой цикл
    const gameLoop = useCallback(
      (currentTime: number) => {
        if (isPaused || !gameState.isRunning) {
          if (gameLoopRef.current) {
            cancelAnimationFrame(gameLoopRef.current);
            gameLoopRef.current = null;
          }
          return;
        }

        const deltaTime = currentTime - lastTimeRef.current;
        lastTimeRef.current = currentTime;

        // Обновляем позиции объектов
        obstaclesRef.current = obstaclesRef.current
          .map((obstacle) => ({
            ...obstacle,
            y: obstacle.y + gameState.gameSpeed * deltaTime * 0.1,
          }))
          .filter(
            (obstacle) => obstacle.y < Dimensions.get("window").height + 100
          );

        coinsRef.current = coinsRef.current
          .map((coin) => ({
            ...coin,
            y: coin.y + gameState.gameSpeed * deltaTime * 0.1,
          }))
          .filter((coin) => coin.y < Dimensions.get("window").height + 100);

        // Создаем новые объекты
        if (Math.random() < 0.01) {
          createObstacle();
        }
        if (Math.random() < 0.02) {
          createCoin();
        }

        // Обновляем дорогу
        roadOffsetRef.current.setValue(
          roadOffsetRef.current._value + gameState.gameSpeed * deltaTime * 0.05
        );

        // Обновляем состояние
        setGameState((prev) => ({
          ...prev,
          distance: prev.distance + gameState.gameSpeed * deltaTime * 0.01,
          obstacles: obstaclesRef.current,
          coins: coinsRef.current,
        }));

        // Вызываем колбэки
        onDistanceUpdate(gameState.distance);
        onScoreUpdate(gameState.score);

        // Продолжаем цикл
        gameLoopRef.current = requestAnimationFrame(gameLoop);
      },
      [
        isPaused,
        gameState.isRunning,
        gameState.gameSpeed,
        gameState.distance,
        gameState.score,
        createObstacle,
        createCoin,
        onDistanceUpdate,
        onScoreUpdate,
      ]
    );

    // Управление игрой
    const start = useCallback(() => {
      setGameState((prev) => ({ ...prev, isRunning: true, isPaused: false }));
      lastTimeRef.current = performance.now();
      gameLoopRef.current = requestAnimationFrame(gameLoop);
    }, [gameLoop]);

    const pause = useCallback(() => {
      setGameState((prev) => ({ ...prev, isPaused: true }));
      if (gameLoopRef.current) {
        cancelAnimationFrame(gameLoopRef.current);
        gameLoopRef.current = null;
      }
    }, []);

    const resume = useCallback(() => {
      setGameState((prev) => ({ ...prev, isPaused: false }));
      lastTimeRef.current = performance.now();
      gameLoopRef.current = requestAnimationFrame(gameLoop);
    }, [gameLoop]);

    const reset = useCallback(() => {
      setGameState({
        isRunning: false,
        isPaused: false,
        score: 0,
        distance: 0,
        playerHealth: 100,
        playerLane: 1,
        obstacles: [],
        coins: [],
        gameSpeed: 1,
      });
      obstaclesRef.current = [];
      coinsRef.current = [];
      playerPositionRef.current.setValue(1);
      roadOffsetRef.current.setValue(0);
      if (gameLoopRef.current) {
        cancelAnimationFrame(gameLoopRef.current);
        gameLoopRef.current = null;
      }
    }, []);

    // Экспорт методов
    useImperativeHandle(
      ref,
      () => ({
        start,
        pause,
        resume,
        reset,
      }),
      [start, pause, resume, reset]
    );

    // Обработка касаний
    const handleTouch = useCallback(
      (event: any) => {
        if (!gameState.isRunning) return;

        const { locationX } = event.nativeEvent;
        const screenWidth = Dimensions.get("window").width;
        const laneWidth = screenWidth / 3;

        let newLane = 1; // По умолчанию центр
        if (locationX < laneWidth) {
          newLane = 0; // Левая полоса
        } else if (locationX > laneWidth * 2) {
          newLane = 2; // Правая полоса
        }

        setGameState((prev) => ({ ...prev, playerLane: newLane }));
        playerPositionRef.current.setValue(newLane);
      },
      [gameState.isRunning]
    );

    // Очистка при размонтировании
    useEffect(() => {
      return () => {
        if (gameLoopRef.current) {
          cancelAnimationFrame(gameLoopRef.current);
        }
      };
    }, []);

    const { width, height } = Dimensions.get("window");
    const laneWidth = width / 3;

    return (
      <View style={styles.container} onTouchStart={handleTouch}>
        {/* Дорога */}
        <Animated.View
          style={[
            styles.road,
            {
              transform: [{ translateY: roadOffsetRef.current }],
            },
          ]}
        >
          {/* Полосы дороги */}
          <View style={[styles.lane, { left: 0 }]} />
          <View style={[styles.lane, { left: laneWidth }]} />
          <View style={[styles.lane, { left: laneWidth * 2 }]} />
        </Animated.View>

        {/* Игрок */}
        <Animated.View
          style={[
            styles.player,
            {
              left: playerPositionRef.current.interpolate({
                inputRange: [0, 1, 2],
                outputRange: [
                  laneWidth * 0.5 - 25,
                  laneWidth * 1.5 - 25,
                  laneWidth * 2.5 - 25,
                ],
              }),
            },
          ]}
        />

        {/* Препятствия */}
        {obstaclesRef.current.map((obstacle) => (
          <View
            key={obstacle.id}
            style={[
              styles.obstacle,
              {
                left: laneWidth * obstacle.lane + laneWidth * 0.5 - 25,
                top: obstacle.y,
                backgroundColor:
                  obstacle.type === "barrier"
                    ? "#ff0000"
                    : obstacle.type === "cone"
                    ? "#ffff00"
                    : "#0000ff",
              },
            ]}
          />
        ))}

        {/* Монеты */}
        {coinsRef.current.map((coin) => (
          <View
            key={coin.id}
            style={[
              styles.coin,
              {
                left: laneWidth * coin.lane + laneWidth * 0.5 - 15,
                top: coin.y,
              },
            ]}
          />
        ))}
      </View>
    );
  }
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#87ceeb", // Небесно-голубой фон
  },
  road: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    height: 2000, // Длинная дорога
    backgroundColor: "#696969", // Темно-серый цвет дороги
  },
  lane: {
    position: "absolute",
    top: 0,
    width: 2,
    height: "100%",
    backgroundColor: "#ffffff", // Белые линии разметки
  },
  player: {
    position: "absolute",
    top: "80%",
    width: 50,
    height: 50,
    backgroundColor: "#00ff00", // Зеленый игрок
    borderRadius: 25,
  },
  obstacle: {
    position: "absolute",
    width: 50,
    height: 50,
  },
  coin: {
    position: "absolute",
    width: 30,
    height: 30,
    backgroundColor: "#ffd700", // Золотая монета
    borderRadius: 15,
  },
});

export default GameRenderer2D;
