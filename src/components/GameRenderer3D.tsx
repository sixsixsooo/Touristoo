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
import { OBJLoader } from "three-stdlib";
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
      console.log("Initializing scene...");
      // Create scene
      const scene = new THREE.Scene();
      // Убираем фон и туман для лучшей видимости объектов
      // scene.background = new THREE.Color(0x87ceeb); // Sky blue background
      // scene.fog = new THREE.Fog(0x87ceeb, 50, 200);
      sceneRef.current = scene;
      console.log("Scene created without background");

      // Create camera
      const camera = new THREE.PerspectiveCamera(
        60, // Уменьшаем FOV для лучшего обзора
        Dimensions.get("window").width / Dimensions.get("window").height,
        0.1,
        1000
      );
      camera.position.set(0, 1, 3); // Камера выше и ближе
      camera.lookAt(0, 0, 0); // Смотрим прямо на объекты
      cameraRef.current = camera;
      console.log("Camera created at position:", camera.position);

      // Добавим очень простые тестовые объекты прямо перед камерой
      const testGeometry = new THREE.BoxGeometry(1, 1, 1);
      const testMaterial = new THREE.MeshBasicMaterial({ color: 0xff0000 }); // Используем BasicMaterial
      const testCube = new THREE.Mesh(testGeometry, testMaterial);
      testCube.position.set(0, 0, 0); // Прямо перед камерой
      scene.add(testCube);
      console.log("Added red cube at position:", testCube.position);

      const testCube2 = new THREE.Mesh(testGeometry, testMaterial);
      testCube2.position.set(2, 0, 0);
      testCube2.material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
      scene.add(testCube2);
      console.log("Added green cube at position:", testCube2.position);

      const sphereGeometry = new THREE.SphereGeometry(0.5, 8, 6);
      const sphereMaterial = new THREE.MeshBasicMaterial({ color: 0x0000ff });
      const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
      sphere.position.set(-2, 0, 0);
      scene.add(sphere);
      console.log("Added blue sphere at position:", sphere.position);

      // Добавим плоскость как фон
      const planeGeometry = new THREE.PlaneGeometry(10, 10);
      const planeMaterial = new THREE.MeshBasicMaterial({ color: 0xffff00 });
      const plane = new THREE.Mesh(planeGeometry, planeMaterial);
      plane.position.set(0, 0, -3);
      plane.rotation.x = -Math.PI / 2;
      scene.add(plane);
      console.log("Added yellow plane at position:", plane.position);

      // Создаем простой стул из геометрии
      try {
        const chairGeometry = new THREE.BoxGeometry(1, 2, 1);
        const chairMaterial = new THREE.MeshBasicMaterial({ color: 0x8b4513 }); // Коричневый цвет
        const chair = new THREE.Mesh(chairGeometry, chairMaterial);
        chair.position.set(0, -1, 0); // Размещаем стул перед камерой
        scene.add(chair);
        console.log("Added simple chair to scene");
      } catch (error) {
        console.error("Error creating chair:", error);
      }

      console.log("Test objects added for visibility check");

      // Create lighting - простое освещение для BasicMaterial
      const ambientLight = new THREE.AmbientLight(0xffffff, 1.0);
      scene.add(ambientLight);
      console.log("Added ambient light");

      // Create road system (temporarily disabled for testing)
      const roadWidth = 6;
      const roadLength = 200;
      const laneWidth = roadWidth / 3;

      // Временно отключаем создание дороги для тестирования
      /*

      // Main road with texture pattern
      const roadGeometry = new THREE.PlaneGeometry(roadWidth, roadLength);
      const roadMaterial = new THREE.MeshLambertMaterial({
        color: 0x2c2c2c,
      });
      const road = new THREE.Mesh(roadGeometry, roadMaterial);
      road.rotation.x = -Math.PI / 2;
      road.position.set(0, 0, -roadLength / 2);
      road.receiveShadow = true;
      scene.add(road);

      // Road shoulders
      const shoulderGeometry = new THREE.PlaneGeometry(2, roadLength);
      const shoulderMaterial = new THREE.MeshLambertMaterial({
        color: 0x8b4513,
      });
      const leftShoulder = new THREE.Mesh(shoulderGeometry, shoulderMaterial);
      leftShoulder.rotation.x = -Math.PI / 2;
      leftShoulder.position.set(-4, 0, -roadLength / 2);
      leftShoulder.receiveShadow = true;
      scene.add(leftShoulder);

      const rightShoulder = new THREE.Mesh(shoulderGeometry, shoulderMaterial);
      rightShoulder.rotation.x = -Math.PI / 2;
      rightShoulder.position.set(4, 0, -roadLength / 2);
      rightShoulder.receiveShadow = true;
      scene.add(rightShoulder);

      // Lane dividers (yellow lines)
      for (let i = 0; i < roadLength; i += 2) {
        const dividerGeometry = new THREE.BoxGeometry(0.1, 0.1, 1);
        const dividerMaterial = new THREE.MeshLambertMaterial({
          color: 0xffff00,
        });
        const divider = new THREE.Mesh(dividerGeometry, dividerMaterial);
        divider.position.set(0, 0.01, -roadLength / 2 + i);
        scene.add(divider);
      }

      // Lane lines (white lines)
      for (let lane = -1; lane <= 1; lane++) {
        const x = lane * laneWidth;
        for (let i = 0; i < roadLength; i += 2) {
          const lineGeometry = new THREE.BoxGeometry(0.05, 0.01, 1);
          const lineMaterial = new THREE.MeshLambertMaterial({
            color: 0xffffff,
          });
          const line = new THREE.Mesh(lineGeometry, lineMaterial);
          line.position.set(x, 0.01, -roadLength / 2 + i);
          scene.add(line);
        }
      }

      // Ground around road
      const groundGeometry = new THREE.PlaneGeometry(50, roadLength);
      const groundMaterial = new THREE.MeshLambertMaterial({ color: 0x90ee90 });
      const ground = new THREE.Mesh(groundGeometry, groundMaterial);
      ground.rotation.x = -Math.PI / 2;
      ground.position.set(0, -0.01, -roadLength / 2);
      ground.receiveShadow = true;
      scene.add(ground);
      */

      // Create player (character) - временно отключен для тестирования
      /*
      const playerGroup = new THREE.Group();

      // Тело персонажа
      const bodyGeometry = new THREE.CapsuleGeometry(0.25, 0.6, 4, 8);
      const bodyMaterial = new THREE.MeshLambertMaterial({ color: 0x4a90e2 });
      const body = new THREE.Mesh(bodyGeometry, bodyMaterial);
      body.position.y = 0.3;
      body.castShadow = true;
      playerGroup.add(body);

      // Голова
      const headGeometry = new THREE.SphereGeometry(0.2, 8, 6);
      const headMaterial = new THREE.MeshLambertMaterial({ color: 0xffdbac });
      const head = new THREE.Mesh(headGeometry, headMaterial);
      head.position.y = 0.8;
      head.castShadow = true;
      playerGroup.add(head);

      // Руки
      const armGeometry = new THREE.CapsuleGeometry(0.08, 0.4, 4, 4);
      const armMaterial = new THREE.MeshLambertMaterial({ color: 0xffdbac });

      const leftArm = new THREE.Mesh(armGeometry, armMaterial);
      leftArm.position.set(-0.3, 0.4, 0);
      leftArm.rotation.z = 0.3;
      leftArm.castShadow = true;
      playerGroup.add(leftArm);

      const rightArm = new THREE.Mesh(armGeometry, armMaterial);
      rightArm.position.set(0.3, 0.4, 0);
      rightArm.rotation.z = -0.3;
      rightArm.castShadow = true;
      playerGroup.add(rightArm);

      // Ноги
      const legGeometry = new THREE.CapsuleGeometry(0.1, 0.5, 4, 4);
      const legMaterial = new THREE.MeshLambertMaterial({ color: 0x2c3e50 });

      const leftLeg = new THREE.Mesh(legGeometry, legMaterial);
      leftLeg.position.set(-0.15, -0.1, 0);
      leftLeg.castShadow = true;
      playerGroup.add(leftLeg);

      const rightLeg = new THREE.Mesh(legGeometry, legMaterial);
      rightLeg.position.set(0.15, -0.1, 0);
      rightLeg.castShadow = true;
      playerGroup.add(rightLeg);

      playerGroup.position.set(0, 0.5, 0);
      scene.add(playerGroup);
      playerRef.current = playerGroup;
      console.log("Player created and added to scene");
      */

      return scene;
    }, []);

    const createObstacles = useCallback(() => {
      if (!sceneRef.current) return;

      // Clear old obstacles
      obstaclesRef.current.forEach((obstacle) => {
        sceneRef.current?.remove(obstacle);
      });
      obstaclesRef.current = [];

      // Create obstacle types - более детализированные модели
      const obstacleTypes = [
        // Дорожный барьер
        {
          create: () => {
            const barrierGroup = new THREE.Group();

            // Основание
            const baseGeometry = new THREE.BoxGeometry(1.2, 0.2, 0.8);
            const baseMaterial = new THREE.MeshLambertMaterial({
              color: 0x2c2c2c,
            });
            const base = new THREE.Mesh(baseGeometry, baseMaterial);
            base.position.y = 0.1;
            base.castShadow = true;
            barrierGroup.add(base);

            // Основная часть
            const mainGeometry = new THREE.BoxGeometry(1, 1.6, 0.6);
            const mainMaterial = new THREE.MeshLambertMaterial({
              color: 0xff0000,
            });
            const main = new THREE.Mesh(mainGeometry, mainMaterial);
            main.position.y = 1;
            main.castShadow = true;
            barrierGroup.add(main);

            // Белые полосы
            for (let i = 0; i < 3; i++) {
              const stripeGeometry = new THREE.BoxGeometry(1.1, 0.1, 0.05);
              const stripeMaterial = new THREE.MeshLambertMaterial({
                color: 0xffffff,
              });
              const stripe = new THREE.Mesh(stripeGeometry, stripeMaterial);
              stripe.position.set(0, 0.5 + i * 0.3, 0.3);
              barrierGroup.add(stripe);
            }

            return barrierGroup;
          },
        },
        // Дорожный конус
        {
          create: () => {
            const coneGroup = new THREE.Group();

            // Основание
            const baseGeometry = new THREE.CylinderGeometry(0.4, 0.4, 0.1, 8);
            const baseMaterial = new THREE.MeshLambertMaterial({
              color: 0x2c2c2c,
            });
            const base = new THREE.Mesh(baseGeometry, baseMaterial);
            base.position.y = 0.05;
            base.castShadow = true;
            coneGroup.add(base);

            // Конус
            const coneGeometry = new THREE.ConeGeometry(0.3, 1.8, 8);
            const coneMaterial = new THREE.MeshLambertMaterial({
              color: 0xff6600,
            });
            const cone = new THREE.Mesh(coneGeometry, coneMaterial);
            cone.position.y = 1;
            cone.castShadow = true;
            coneGroup.add(cone);

            // Белые полосы
            for (let i = 0; i < 2; i++) {
              const stripeGeometry = new THREE.CylinderGeometry(
                0.32,
                0.32,
                0.05,
                8
              );
              const stripeMaterial = new THREE.MeshLambertMaterial({
                color: 0xffffff,
              });
              const stripe = new THREE.Mesh(stripeGeometry, stripeMaterial);
              stripe.position.y = 0.3 + i * 0.6;
              coneGroup.add(stripe);
            }

            return coneGroup;
          },
        },
        // Строительный блок
        {
          create: () => {
            const blockGroup = new THREE.Group();

            // Основной блок
            const blockGeometry = new THREE.BoxGeometry(1, 1.5, 1);
            const blockMaterial = new THREE.MeshLambertMaterial({
              color: 0x8b4513,
            });
            const block = new THREE.Mesh(blockGeometry, blockMaterial);
            block.position.y = 0.75;
            block.castShadow = true;
            blockGroup.add(block);

            // Металлические уголки
            const cornerGeometry = new THREE.BoxGeometry(0.1, 1.5, 0.1);
            const cornerMaterial = new THREE.MeshLambertMaterial({
              color: 0x708090,
            });

            const corners = [
              [-0.45, 0.75, -0.45],
              [0.45, 0.75, -0.45],
              [-0.45, 0.75, 0.45],
              [0.45, 0.75, 0.45],
            ];

            corners.forEach((pos) => {
              const corner = new THREE.Mesh(cornerGeometry, cornerMaterial);
              corner.position.set(pos[0], pos[1], pos[2]);
              corner.castShadow = true;
              blockGroup.add(corner);
            });

            return blockGroup;
          },
        },
      ];

      // Create obstacles
      for (let i = 0; i < 30; i++) {
        const typeIndex = Math.floor(Math.random() * obstacleTypes.length);
        const obstacle = obstacleTypes[typeIndex].create();

        const lane = Math.floor(Math.random() * 3) - 1; // -1, 0, 1
        obstacle.position.set(
          lane * 2, // Lane position (-2, 0, 2)
          0,
          -i * 15 - 30 // Distance along Z
        );

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

      // Create coins - более детализированные
      for (let i = 0; i < 60; i++) {
        const coinGroup = new THREE.Group();

        // Основная монета
        const coinGeometry = new THREE.CylinderGeometry(0.3, 0.3, 0.05, 12);
        const coinMaterial = new THREE.MeshLambertMaterial({
          color: 0xffd700,
          emissive: 0x444400,
          emissiveIntensity: 0.3,
        });
        const coin = new THREE.Mesh(coinGeometry, coinMaterial);
        coin.castShadow = true;
        coinGroup.add(coin);

        // Внутренний круг
        const innerGeometry = new THREE.CylinderGeometry(0.2, 0.2, 0.06, 12);
        const innerMaterial = new THREE.MeshLambertMaterial({
          color: 0xffed4e,
          emissive: 0x222200,
          emissiveIntensity: 0.2,
        });
        const inner = new THREE.Mesh(innerGeometry, innerMaterial);
        coinGroup.add(inner);

        // Блеск
        const sparkleGeometry = new THREE.SphereGeometry(0.05, 6, 4);
        const sparkleMaterial = new THREE.MeshLambertMaterial({
          color: 0xffffff,
          emissive: 0xffffff,
          emissiveIntensity: 0.5,
        });
        const sparkle = new THREE.Mesh(sparkleGeometry, sparkleMaterial);
        sparkle.position.set(0.1, 0, 0.03);
        coinGroup.add(sparkle);

        const lane = Math.floor(Math.random() * 3) - 1; // -1, 0, 1
        coinGroup.position.set(
          lane * 2, // Lane position (-2, 0, 2)
          2,
          -i * 8 - 20 // Distance along Z
        );

        sceneRef.current.add(coinGroup);
        coinsRef.current.push(coinGroup);
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
          // Move road forward
          const roadSpeed = gameSpeedRef.current * deltaTime;
          sceneRef.current.children.forEach((child) => {
            // Move road elements
            if (
              child.material &&
              (child.material.color.getHex() === 0x333333 || // Road
                child.material.color.getHex() === 0xffff00 || // Yellow dividers
                child.material.color.getHex() === 0xffffff) // White lines
            ) {
              child.position.z += roadSpeed;

              // Reset position when road goes too far
              if (child.position.z > 100) {
                child.position.z = -100;
              }
            }
          });

          // Update player position based on lane
          if (playerRef.current) {
            const targetX = playerLaneRef.current * 2; // 3 lanes: -2, 0, 2
            playerRef.current.position.x +=
              (targetX - playerRef.current.position.x) * 0.1;

            // Анимация бега - покачивание рук и ног
            const time = currentTime * 0.01;
            if (playerRef.current.children.length > 2) {
              // Левая рука
              playerRef.current.children[2].rotation.z =
                0.3 + Math.sin(time * 10) * 0.2;
              // Правая рука
              playerRef.current.children[3].rotation.z =
                -0.3 - Math.sin(time * 10) * 0.2;
              // Левая нога
              playerRef.current.children[4].rotation.x =
                Math.sin(time * 10) * 0.3;
              // Правая нога
              playerRef.current.children[5].rotation.x =
                -Math.sin(time * 10) * 0.3;
            }
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
            coin.rotation.y += deltaTime * 8; // Coin rotation
            coin.rotation.x += deltaTime * 3; // Additional rotation for sparkle effect

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
              coin.position.x = lane * 2; // Updated lane position
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
        if (rendererRef.current && sceneRef.current && cameraRef.current) {
          rendererRef.current.render(sceneRef.current, cameraRef.current);
          // Логируем каждый кадр для отладки
          console.log(
            "Rendering frame, scene objects:",
            sceneRef.current.children.length
          );
          console.log("Camera position:", cameraRef.current.position);
          console.log("Camera rotation:", cameraRef.current.rotation);
        } else {
          console.log("Missing renderer, scene, or camera:", {
            renderer: !!rendererRef.current,
            scene: !!sceneRef.current,
            camera: !!cameraRef.current,
          });
        }
        animationRef.current = requestAnimationFrame(gameLoop);
      },
      [gameState, onScoreUpdate, onDistanceUpdate, onHealthUpdate, onGameOver]
    );

    const onContextCreate = useCallback(
      async (gl: any) => {
        console.log("Creating 3D context...");
        console.log("GL object:", gl);
        const { drawingBufferWidth: width, drawingBufferHeight: height } = gl;
        console.log("Canvas size:", width, "x", height);

        if (!gl || !width || !height) {
          console.error("Invalid GL context or dimensions:", {
            gl,
            width,
            height,
          });
          return;
        }

        // Create renderer
        const renderer = new Renderer({ gl });
        renderer.setSize(width, height);
        renderer.setPixelRatio(devicePixelRatio);
        renderer.setClearColor(0x000000, 0); // Прозрачный фон
        renderer.shadowMap.enabled = true;
        renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        renderer.autoClear = true;
        rendererRef.current = renderer;
        console.log("Renderer created with transparent background");

        // Initialize scene
        const scene = initializeScene();
        sceneRef.current = scene;
        console.log("Scene initialized with", scene.children.length, "objects");

        // Start game loop
        lastTimeRef.current = performance.now();
        animationRef.current = requestAnimationFrame(gameLoop);
        console.log("Game loop started");
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

    console.log("Rendering GameRenderer3D component");

    const { width, height } = Dimensions.get("window");

    return (
      <View style={styles.container}>
        <GLView
          style={[styles.glView, { width, height }]}
          onContextCreate={onContextCreate}
          onTouchStart={handleTouch}
          msaaSamples={0}
          enableExperimentalWorklets={false}
        />
      </View>
    );
  }
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "transparent",
  },
  glView: {
    flex: 1,
    width: "100%",
    height: "100%",
    backgroundColor: "transparent",
  },
});

export default GameRenderer3D;
