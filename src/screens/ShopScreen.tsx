import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  SafeAreaView,
  Alert,
  Image,
} from "react-native";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "@/store";
import { Skin } from "@/types";
import { adsService } from "@/services/adsService";

const ShopScreen: React.FC = () => {
  const dispatch = useDispatch();
  const { currentPlayer, skins } = useSelector(
    (state: RootState) => state.player
  );
  const { coins } = useSelector((state: RootState) => state.game);
  const [selectedCategory, setSelectedCategory] = useState<
    "skins" | "boosters" | "coins"
  >("skins");

  // Моковые данные для магазина
  const mockSkins: Skin[] = [
    {
      id: "1",
      name: "Классический бегун",
      description: "Стандартный персонаж",
      price: 0,
      isUnlocked: true,
      modelPath: "models/classic_runner.glb",
      texturePath: "textures/classic_runner.jpg",
      rarity: "common",
    },
    {
      id: "2",
      name: "Космический бегун",
      description: "Бегун из будущего",
      price: 100,
      isUnlocked: false,
      modelPath: "models/space_runner.glb",
      texturePath: "textures/space_runner.jpg",
      rarity: "rare",
    },
    {
      id: "3",
      name: "Драконий бегун",
      description: "Мощный дракон-бегун",
      price: 500,
      isUnlocked: false,
      modelPath: "models/dragon_runner.glb",
      texturePath: "textures/dragon_runner.jpg",
      rarity: "epic",
    },
    {
      id: "4",
      name: "Легендарный герой",
      description: "Самый редкий персонаж",
      price: 1000,
      isUnlocked: false,
      modelPath: "models/legend_runner.glb",
      texturePath: "textures/legend_runner.jpg",
      rarity: "legendary",
    },
  ];

  const mockBoosters = [
    {
      id: "1",
      name: "Щит",
      description: "Защита от одного столкновения",
      price: 50,
      icon: "🛡️",
    },
    {
      id: "2",
      name: "Ускорение",
      description: "Увеличивает скорость на 30 секунд",
      price: 75,
      icon: "⚡",
    },
    {
      id: "3",
      name: "Магнит",
      description: "Притягивает монеты на 20 секунд",
      price: 100,
      icon: "🧲",
    },
  ];

  const mockCoinPacks = [
    {
      id: "1",
      name: "Малый пакет",
      description: "100 монет",
      price: 99,
      currency: "rub",
      icon: "💰",
    },
    {
      id: "2",
      name: "Средний пакет",
      description: "500 монет",
      price: 399,
      currency: "rub",
      icon: "💰💰",
    },
    {
      id: "3",
      name: "Большой пакет",
      description: "1000 монет",
      price: 699,
      currency: "rub",
      icon: "💰💰💰",
    },
  ];

  useEffect(() => {
    // Показываем баннерную рекламу в магазине
    adsService.showBannerAd();
  }, []);

  const handlePurchaseSkin = async (skin: Skin) => {
    if (skin.isUnlocked) {
      // Выбираем скин
      dispatch({ type: "player/setCurrentSkin", payload: skin.id });
      Alert.alert("Успех", `Скин "${skin.name}" выбран!`);
      return;
    }

    if (coins < skin.price) {
      Alert.alert(
        "Недостаточно монет",
        `Вам нужно ${skin.price - coins} монет для покупки этого скина.`,
        [
          { text: "Отмена", style: "cancel" },
          {
            text: "Купить монеты",
            onPress: () => setSelectedCategory("coins"),
          },
        ]
      );
      return;
    }

    // Покупка скина за монеты
    Alert.alert(
      "Подтверждение покупки",
      `Купить скин "${skin.name}" за ${skin.price} монет?`,
      [
        { text: "Отмена", style: "cancel" },
        {
          text: "Купить",
          onPress: () => {
            dispatch({ type: "player/unlockSkin", payload: skin.id });
            dispatch({ type: "game/spendCoins", payload: skin.price });
            Alert.alert("Успех", `Скин "${skin.name}" куплен!`);
          },
        },
      ]
    );
  };

  const handlePurchaseBooster = (booster: any) => {
    if (coins < booster.price) {
      Alert.alert(
        "Недостаточно монет",
        `Вам нужно ${booster.price - coins} монет для покупки этого бустера.`
      );
      return;
    }

    Alert.alert(
      "Подтверждение покупки",
      `Купить "${booster.name}" за ${booster.price} монет?`,
      [
        { text: "Отмена", style: "cancel" },
        {
          text: "Купить",
          onPress: () => {
            dispatch({ type: "game/spendCoins", payload: booster.price });
            Alert.alert("Успех", `Бустер "${booster.name}" куплен!`);
          },
        },
      ]
    );
  };

  const handlePurchaseCoins = async (coinPack: any) => {
    // В реальном приложении здесь будет интеграция с платежной системой
    Alert.alert(
      "Покупка монет",
      `Купить ${coinPack.description} за ${coinPack.price}₽?`,
      [
        { text: "Отмена", style: "cancel" },
        {
          text: "Купить",
          onPress: async () => {
            // Показываем рекламу за монеты как альтернативу
            const result = await adsService.showRewardedAd();
            if (result.success) {
              const coinsToAdd = parseInt(coinPack.description.split(" ")[0]);
              dispatch({ type: "game/addCoins", payload: coinsToAdd });
              Alert.alert("Успех", `Получено ${coinsToAdd} монет!`);
            }
          },
        },
      ]
    );
  };

  const renderSkin = ({ item }: { item: Skin }) => (
    <TouchableOpacity
      style={[
        styles.item,
        item.isUnlocked && styles.unlockedItem,
        item.rarity === "legendary" && styles.legendaryItem,
      ]}
      onPress={() => handlePurchaseSkin(item)}
    >
      <View style={styles.itemHeader}>
        <Text style={styles.itemName}>{item.name}</Text>
        <Text style={styles.itemPrice}>
          {item.isUnlocked ? "✓" : `${item.price} монет`}
        </Text>
      </View>
      <Text style={styles.itemDescription}>{item.description}</Text>
      <View style={styles.rarityBadge}>
        <Text style={styles.rarityText}>
          {item.rarity === "common" && "Обычный"}
          {item.rarity === "rare" && "Редкий"}
          {item.rarity === "epic" && "Эпический"}
          {item.rarity === "legendary" && "Легендарный"}
        </Text>
      </View>
    </TouchableOpacity>
  );

  const renderBooster = ({ item }: { item: any }) => (
    <TouchableOpacity
      style={styles.item}
      onPress={() => handlePurchaseBooster(item)}
    >
      <View style={styles.itemHeader}>
        <Text style={styles.itemName}>
          {item.icon} {item.name}
        </Text>
        <Text style={styles.itemPrice}>{item.price} монет</Text>
      </View>
      <Text style={styles.itemDescription}>{item.description}</Text>
    </TouchableOpacity>
  );

  const renderCoinPack = ({ item }: { item: any }) => (
    <TouchableOpacity
      style={styles.item}
      onPress={() => handlePurchaseCoins(item)}
    >
      <View style={styles.itemHeader}>
        <Text style={styles.itemName}>
          {item.icon} {item.name}
        </Text>
        <Text style={styles.itemPrice}>{item.price}₽</Text>
      </View>
      <Text style={styles.itemDescription}>{item.description}</Text>
    </TouchableOpacity>
  );

  const renderContent = () => {
    switch (selectedCategory) {
      case "skins":
        return (
          <FlatList
            data={mockSkins}
            renderItem={renderSkin}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
          />
        );
      case "boosters":
        return (
          <FlatList
            data={mockBoosters}
            renderItem={renderBooster}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
          />
        );
      case "coins":
        return (
          <FlatList
            data={mockCoinPacks}
            renderItem={renderCoinPack}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
          />
        );
      default:
        return null;
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Магазин</Text>
        <View style={styles.coinsContainer}>
          <Text style={styles.coinsText}>💰 {coins}</Text>
        </View>
      </View>

      <View style={styles.categoryTabs}>
        <TouchableOpacity
          style={[styles.tab, selectedCategory === "skins" && styles.activeTab]}
          onPress={() => setSelectedCategory("skins")}
        >
          <Text
            style={[
              styles.tabText,
              selectedCategory === "skins" && styles.activeTabText,
            ]}
          >
            Скины
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[
            styles.tab,
            selectedCategory === "boosters" && styles.activeTab,
          ]}
          onPress={() => setSelectedCategory("boosters")}
        >
          <Text
            style={[
              styles.tabText,
              selectedCategory === "boosters" && styles.activeTabText,
            ]}
          >
            Бустеры
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, selectedCategory === "coins" && styles.activeTab]}
          onPress={() => setSelectedCategory("coins")}
        >
          <Text
            style={[
              styles.tabText,
              selectedCategory === "coins" && styles.activeTabText,
            ]}
          >
            Монеты
          </Text>
        </TouchableOpacity>
      </View>

      <View style={styles.content}>{renderContent()}</View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f0f0f0",
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    padding: 20,
    backgroundColor: "#fff",
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
  coinsContainer: {
    backgroundColor: "#FFD700",
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  coinsText: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#333",
  },
  categoryTabs: {
    flexDirection: "row",
    backgroundColor: "#fff",
    marginHorizontal: 20,
    marginTop: 10,
    borderRadius: 12,
    padding: 4,
  },
  tab: {
    flex: 1,
    paddingVertical: 12,
    alignItems: "center",
    borderRadius: 8,
  },
  activeTab: {
    backgroundColor: "#007AFF",
  },
  tabText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#666",
  },
  activeTabText: {
    color: "#fff",
  },
  content: {
    flex: 1,
    padding: 20,
  },
  item: {
    backgroundColor: "#fff",
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  unlockedItem: {
    borderColor: "#34C759",
    borderWidth: 2,
  },
  legendaryItem: {
    borderColor: "#FFD700",
    borderWidth: 2,
  },
  itemHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  itemName: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#333",
    flex: 1,
  },
  itemPrice: {
    fontSize: 16,
    fontWeight: "600",
    color: "#007AFF",
  },
  itemDescription: {
    fontSize: 14,
    color: "#666",
    marginBottom: 8,
  },
  rarityBadge: {
    alignSelf: "flex-start",
    backgroundColor: "#E0E0E0",
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  rarityText: {
    fontSize: 12,
    fontWeight: "600",
    color: "#333",
  },
});

export default ShopScreen;
