import React, {
  useRef,
  useEffect,
  useState,
  useCallback,
  useImperativeHandle,
  forwardRef,
} from "react";
import { View, StyleSheet, Dimensions } from "react-native";
import { GLView } from "expo-gl";
import { Renderer } from "expo-three";
import * as THREE from "three";
import { GameState } from "@/types";

interface GameRenderer3DProps {
  onScoreUpdate: (score: number) => void;
  onDistanceUpdate: (distance: number) => void;
  onHealthUpdate: (health: number) => void;
  onGameOver: () => void;
  isPaused: boolean;
}

interface GameRenderer3DRef {
  pause: () => void;
  resume: () => void;
  reset: () => void;
  start: () => void;
}

const GameRenderer3D = forwardRef<GameRenderer3DRef, GameRenderer3DProps>(
  (props, ref) => {
    const {
      onScoreUpdate,
      onDistanceUpdate,
      onHealthUpdate,
      onGameOver,
      isPaused,
    } = props;

    const [gameState, setGameState] = useState<GameState>({
      score: 0,
      distance: 0,
      coins: 0,
      isRunning: false,
      isPaused: false,
      currentLevel: 1,
      playerHealth: 100,
      maxHealth: 100,
    });

    const sceneRef = useRef<THREE.Scene>();
    const rendererRef = useRef<Renderer>();
    const cameraRef = useRef<THREE.PerspectiveCamera>();
    const playerRef = useRef<THREE.Mesh>();
    const obstaclesRef = useRef<THREE.Mesh[]>([]);
    const coinsRef = useRef<THREE.Mesh[]>([]);
    const animationRef = useRef<number>();
    const lastTimeRef = useRef<number>(0);
    const gameSpeedRef = useRef<number>(10);
    const playerLaneRef = useRef<number>(0); // -1, 0, 1 for left, center, right

    // Expose methods through ref
    useImperativeHandle(ref, () => ({
      pause: () => {
        setGameState((prev) => ({ ...prev, isPaused: true }));
      },
      resume: () => {
        setGameState((prev) => ({ ...prev, isPaused: false }));
      },
      reset: () => {
        setGameState({
          score: 0,
          distance: 0,
          coins: 0,
          isRunning: false,
          isPaused: false,
          currentLevel: 1,
          playerHealth: 100,
          maxHealth: 100,
        });
        gameSpeedRef.current = 10;
        playerLaneRef.current = 0;
        resetGameObjects();
      },
      start: () => {
        setGameState((prev) => ({ ...prev, isRunning: true, isPaused: false }));
      },
    }));

    const resetGameObjects = useCallback(() => {
      if (!sceneRef.current) return;

      // Reset player position
      if (playerRef.current) {
        playerRef.current.position.set(0, 1, 0);
      }

      // Reset obstacles
      obstaclesRef.current.forEach((obstacle) => {
        obstacle.position.z = -1000;
      });

      // Reset coins
      coinsRef.current.forEach((coin) => {
        coin.position.z = -1000;
      });
    }, []);

    const initializeScene = useCallback(() => {
      // Create scene
      const scene = new THREE.Scene();
      scene.background = new THREE.Color(0x87ceeb); // Sky blue background
      scene.fog = new THREE.Fog(0x87ceeb, 50, 200);
      sceneRef.current = scene;

      // Create camera
      const camera = new THREE.PerspectiveCamera(
        75,
        Dimensions.get("window").width / Dimensions.get("window").height,
        0.1,
        1000
      );
      camera.position.set(0, 8, 15);
      camera.lookAt(0, 0, 0);
      cameraRef.current = camera;

      // Create lighting
      const ambientLight = new THREE.AmbientLight(0x404040, 0.4);
      scene.add(ambientLight);

      const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
      directionalLight.position.set(10, 20, 10);
      directionalLight.castShadow = true;
      directionalLight.shadow.mapSize.width = 2048;
      directionalLight.shadow.mapSize.height = 2048;
      directionalLight.shadow.camera.near = 0.5;
      directionalLight.shadow.camera.far = 50;
      directionalLight.shadow.camera.left = -20;
      directionalLight.shadow.camera.right = 20;
      directionalLight.shadow.camera.top = 20;
      directionalLight.shadow.camera.bottom = -20;
      scene.add(directionalLight);

      // Create player (character) - используем BoxGeometry вместо CapsuleGeometry для совместимости
      const playerGeometry = new THREE.CapsuleGeometry(0.5, 1.5, 4, 8);
      const playerMaterial = new THREE.MeshLambertMaterial({ color: 0x00ff00 });
      const player = new THREE.Mesh(playerGeometry, playerMaterial);
      player.position.set(0, 1, 0);
      player.castShadow = true;
      scene.add(player);
      playerRef.current = player;

      // Create ground
      const groundGeometry = new THREE.PlaneGeometry(20, 1000);
      const groundMaterial = new THREE.MeshLambertMaterial({
        color: 0x90ee90,
        transparent: true,
        opacity: 0.8,
      });
      const ground = new THREE.Mesh(groundGeometry, groundMaterial);
      ground.rotation.x = -Math.PI / 2;
      ground.position.y = 0;
      ground.receiveShadow = true;
      scene.add(ground);

      // Create road markings
      for (let i = 0; i < 100; i++) {
        const lineGeometry = new THREE.PlaneGeometry(0.2, 2);
        const lineMaterial = new THREE.MeshLambertMaterial({ color: 0xffffff });
        const line = new THREE.Mesh(lineGeometry, lineMaterial);
        line.rotation.x = -Math.PI / 2;
        line.position.set(0, 0.01, -i * 10);
        scene.add(line);
      }

      // Create obstacles
      createObstacles();

      // Create coins
      createCoins();

      // Create environment objects
      createEnvironment();

      return scene;
    }, []);

    const createObstacles = useCallback(() => {
      if (!sceneRef.current) return;

      // Clear old obstacles
      obstaclesRef.current.forEach((obstacle) => {
        sceneRef.current?.remove(obstacle);
      });
      obstaclesRef.current = [];

      // Create obstacle types
      const obstacleTypes = [
        { geometry: new THREE.BoxGeometry(1, 2, 1), color: 0xff0000 }, // Red box
        { geometry: new THREE.ConeGeometry(0.8, 2, 6), color: 0xff6600 }, // Orange cone
        { geometry: new THREE.CylinderGeometry(0.5, 0.5, 2), color: 0x800080 }, // Purple cylinder
      ];

      // Create obstacles
      for (let i = 0; i < 30; i++) {
        const typeIndex = Math.floor(Math.random() * obstacleTypes.length);
        const { geometry, color } = obstacleTypes[typeIndex];
        const material = new THREE.MeshLambertMaterial({ color });
        const obstacle = new THREE.Mesh(geometry, material);

        const lane = Math.floor(Math.random() * 3) - 1; // -1, 0, 1
        obstacle.position.set(
          lane * 3, // Lane position
          1,
          -i * 15 - 30 // Distance along Z
        );
        obstacle.castShadow = true;

        sceneRef.current.add(obstacle);
        obstaclesRef.current.push(obstacle);
      }
    }, []);

    const createCoins = useCallback(() => {
      if (!sceneRef.current) return;

      // Clear old coins
      coinsRef.current.forEach((coin) => {
        sceneRef.current?.remove(coin);
      });
      coinsRef.current = [];

      // Create coins
      for (let i = 0; i < 60; i++) {
        const geometry = new THREE.CylinderGeometry(0.3, 0.3, 0.1, 8);
        const material = new THREE.MeshLambertMaterial({
          color: 0xffd700,
          emissive: 0x444400,
          emissiveIntensity: 0.3,
        });
        const coin = new THREE.Mesh(geometry, material);

        const lane = Math.floor(Math.random() * 3) - 1; // -1, 0, 1
        coin.position.set(
          lane * 3, // Lane position
          2,
          -i * 8 - 20 // Distance along Z
        );
        coin.castShadow = true;

        sceneRef.current.add(coin);
        coinsRef.current.push(coin);
      }
    }, []);

    const createEnvironment = useCallback(() => {
      if (!sceneRef.current) return;

      // Create trees on the sides
      for (let i = 0; i < 50; i++) {
        const treeGeometry = new THREE.CylinderGeometry(0.3, 0.5, 3);
        const treeMaterial = new THREE.MeshLambertMaterial({ color: 0x228b22 });
        const tree = new THREE.Mesh(treeGeometry, treeMaterial);

        const side = Math.random() > 0.5 ? 1 : -1;
        tree.position.set(
          side * (8 + Math.random() * 5), // Random position on the side
          1.5,
          -i * 20 - 50
        );
        tree.castShadow = true;

        sceneRef.current.add(tree);
      }

      // Create clouds
      for (let i = 0; i < 20; i++) {
        const cloudGeometry = new THREE.SphereGeometry(2, 8, 6);
        const cloudMaterial = new THREE.MeshLambertMaterial({
          color: 0xffffff,
          transparent: true,
          opacity: 0.6,
        });
        const cloud = new THREE.Mesh(cloudGeometry, cloudMaterial);

        cloud.position.set(
          (Math.random() - 0.5) * 40,
          15 + Math.random() * 10,
          -i * 50 - 100
        );
        cloud.scale.set(
          1 + Math.random(),
          0.5 + Math.random() * 0.5,
          1 + Math.random()
        );

        sceneRef.current.add(cloud);
      }
    }, []);

    const handleTouch = useCallback(
      (event: any) => {
        if (!gameState.isRunning || gameState.isPaused) return;

        const { locationX } = event.nativeEvent;
        const screenWidth = Dimensions.get("window").width;

        if (locationX < screenWidth / 3) {
          // Left lane
          playerLaneRef.current = Math.max(-1, playerLaneRef.current - 1);
        } else if (locationX > (screenWidth * 2) / 3) {
          // Right lane
          playerLaneRef.current = Math.min(1, playerLaneRef.current + 1);
        }
        // Center lane is default
      },
      [gameState.isRunning, gameState.isPaused]
    );

    const gameLoop = useCallback(
      (currentTime: number) => {
        if (!sceneRef.current || !rendererRef.current || !cameraRef.current)
          return;

        const deltaTime = (currentTime - lastTimeRef.current) / 1000;
        lastTimeRef.current = currentTime;

        if (!gameState.isPaused && gameState.isRunning) {
          // Update player position based on lane
          if (playerRef.current) {
            const targetX = playerLaneRef.current * 3;
            playerRef.current.position.x +=
              (targetX - playerRef.current.position.x) * 0.1;
          }

          // Update obstacles
          obstaclesRef.current.forEach((obstacle) => {
            obstacle.position.z += gameSpeedRef.current * deltaTime;

            // Check collision with player
            if (playerRef.current) {
              const distance = playerRef.current.position.distanceTo(
                obstacle.position
              );
              if (distance < 1.2) {
                // Collision!
                const newHealth = Math.max(0, gameState.playerHealth - 20);
                onHealthUpdate(newHealth);

                if (newHealth <= 0) {
                  onGameOver();
                }

                obstacle.position.z = -1000; // Remove obstacle
              }
            }

            // Reset obstacle position
            if (obstacle.position.z > 20) {
              obstacle.position.z = -1000;
              const lane = Math.floor(Math.random() * 3) - 1;
              obstacle.position.x = lane * 3;
            }
          });

          // Update coins
          coinsRef.current.forEach((coin) => {
            coin.position.z += gameSpeedRef.current * deltaTime;
            coin.rotation.y += deltaTime * 5; // Coin rotation

            // Check coin collection
            if (playerRef.current) {
              const distance = playerRef.current.position.distanceTo(
                coin.position
              );
              if (distance < 1) {
                // Collect coin!
                const newScore = gameState.score + 10;
                const newCoins = gameState.coins + 1;
                onScoreUpdate(newScore);
                setGameState((prev) => ({ ...prev, coins: newCoins }));
                coin.position.z = -1000; // Remove coin
              }
            }

            // Reset coin position
            if (coin.position.z > 20) {
              coin.position.z = -1000;
              const lane = Math.floor(Math.random() * 3) - 1;
              coin.position.x = lane * 3;
            }
          });

          // Update distance and speed
          const newDistance =
            gameState.distance + deltaTime * gameSpeedRef.current;
          onDistanceUpdate(newDistance);

          // Increase speed over time
          gameSpeedRef.current = Math.min(25, 10 + newDistance / 100);

          // Level up based on distance
          const newLevel = Math.floor(newDistance / 100) + 1;
          if (newLevel > gameState.currentLevel) {
            setGameState((prev) => ({ ...prev, currentLevel: newLevel }));
          }
        }

        // Render scene
        rendererRef.current.render(sceneRef.current, cameraRef.current);
        animationRef.current = requestAnimationFrame(gameLoop);
      },
      [gameState, onScoreUpdate, onDistanceUpdate, onHealthUpdate, onGameOver]
    );

    const onContextCreate = useCallback(
      async (gl: any) => {
        const { drawingBufferWidth: width, drawingBufferHeight: height } = gl;

        // Create renderer
        const renderer = new Renderer({ gl });
        renderer.setSize(width, height);
        renderer.setClearColor(0x87ceeb);
        renderer.shadowMap.enabled = true;
        renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        rendererRef.current = renderer;

        // Initialize scene
        const scene = initializeScene();
        sceneRef.current = scene;

        // Start game loop
        lastTimeRef.current = performance.now();
        animationRef.current = requestAnimationFrame(gameLoop);
      },
      [initializeScene, gameLoop]
    );

    useEffect(() => {
      if (gameState.isRunning && !gameState.isPaused) {
        if (!animationRef.current) {
          lastTimeRef.current = performance.now();
          animationRef.current = requestAnimationFrame(gameLoop);
        }
      } else if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
        animationRef.current = undefined;
      }
    }, [gameState.isRunning, gameState.isPaused, gameLoop]);

    useEffect(() => {
      return () => {
        if (animationRef.current) {
          cancelAnimationFrame(animationRef.current);
        }
      };
    }, []);

    return (
      <View style={styles.container}>
        <GLView
          style={styles.glView}
          onContextCreate={onContextCreate}
          onTouchStart={handleTouch}
        />
      </View>
    );
  }
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#000",
  },
  glView: {
    flex: 1,
  },
});

export default GameRenderer3D;
