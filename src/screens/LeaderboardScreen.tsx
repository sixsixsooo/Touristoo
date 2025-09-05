import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  SafeAreaView,
  RefreshControl,
  Alert,
} from "react-native";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "@/store";
import { LeaderboardEntry } from "@/types";
import { apiService } from "@/services/api";
import { storageService } from "@/services/storage";

const LeaderboardScreen: React.FC = () => {
  const dispatch = useDispatch();
  const { entries, currentPlayerRank, isLoading } = useSelector(
    (state: RootState) => state.leaderboard
  );
  const { currentPlayer } = useSelector((state: RootState) => state.player);
  const [selectedTimeRange, setSelectedTimeRange] = useState<
    "daily" | "weekly" | "monthly" | "all"
  >("all");
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    loadLeaderboard();
  }, [selectedTimeRange]);

  const loadLeaderboard = async () => {
    try {
      dispatch({ type: "leaderboard/setLoading", payload: true });

      // Сначала пытаемся загрузить из кэша
      const cachedEntries = await storageService.getCachedLeaderboard(
        selectedTimeRange
      );
      if (cachedEntries.length > 0) {
        dispatch({
          type: "leaderboard/setLeaderboard",
          payload: cachedEntries,
        });
      }

      // Затем загружаем свежие данные с сервера
      const response = await apiService.getLeaderboard({
        timeRange: selectedTimeRange,
        limit: 100,
      });

      if (response.success && response.data) {
        dispatch({
          type: "leaderboard/setLeaderboard",
          payload: response.data,
        });

        // Кэшируем данные
        await storageService.cacheLeaderboard(response.data, selectedTimeRange);
      }
    } catch (error) {
      console.error("Failed to load leaderboard:", error);
      Alert.alert("Ошибка", "Не удалось загрузить рейтинг");
    } finally {
      dispatch({ type: "leaderboard/setLoading", payload: false });
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadLeaderboard();
    setRefreshing(false);
  };

  const getTimeRangeText = (range: string) => {
    switch (range) {
      case "daily":
        return "За день";
      case "weekly":
        return "За неделю";
      case "monthly":
        return "За месяц";
      case "all":
        return "За все время";
      default:
        return "За все время";
    }
  };

  const getRankIcon = (rank: number) => {
    if (rank === 1) return "🥇";
    if (rank === 2) return "🥈";
    if (rank === 3) return "🥉";
    return `#${rank}`;
  };

  const renderPlayer = ({
    item,
    index,
  }: {
    item: LeaderboardEntry;
    index: number;
  }) => {
    const isCurrentPlayer = currentPlayer && item.id === currentPlayer.id;

    return (
      <View
        style={[
          styles.playerItem,
          isCurrentPlayer && styles.currentPlayerItem,
          index < 3 && styles.topPlayerItem,
        ]}
      >
        <View style={styles.rankContainer}>
          <Text
            style={[
              styles.rankText,
              index < 3 && styles.topRankText,
              isCurrentPlayer && styles.currentPlayerRankText,
            ]}
          >
            {getRankIcon(item.rank)}
          </Text>
        </View>

        <View style={styles.playerInfo}>
          <Text
            style={[
              styles.playerName,
              isCurrentPlayer && styles.currentPlayerName,
            ]}
          >
            {item.playerName}
            {isCurrentPlayer && " (Вы)"}
          </Text>
          <Text style={styles.playerScore}>
            {item.score.toLocaleString()} очков
          </Text>
        </View>

        {item.avatar && (
          <View style={styles.avatarContainer}>
            <Text style={styles.avatar}>👤</Text>
          </View>
        )}
      </View>
    );
  };

  const renderHeader = () => (
    <View style={styles.header}>
      <Text style={styles.title}>Рейтинг игроков</Text>

      <View style={styles.timeRangeTabs}>
        {(["daily", "weekly", "monthly", "all"] as const).map((range) => (
          <TouchableOpacity
            key={range}
            style={[
              styles.timeRangeTab,
              selectedTimeRange === range && styles.activeTimeRangeTab,
            ]}
            onPress={() => setSelectedTimeRange(range)}
          >
            <Text
              style={[
                styles.timeRangeTabText,
                selectedTimeRange === range && styles.activeTimeRangeTabText,
              ]}
            >
              {getTimeRangeText(range)}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {currentPlayerRank && (
        <View style={styles.currentPlayerRank}>
          <Text style={styles.currentPlayerRankText}>
            Ваше место: #{currentPlayerRank}
          </Text>
        </View>
      )}
    </View>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Text style={styles.emptyStateText}>📊</Text>
      <Text style={styles.emptyStateTitle}>Рейтинг пуст</Text>
      <Text style={styles.emptyStateDescription}>
        Станьте первым игроком в рейтинге!
      </Text>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        data={entries}
        renderItem={renderPlayer}
        keyExtractor={(item) => item.id}
        ListHeaderComponent={renderHeader}
        ListEmptyComponent={!isLoading ? renderEmptyState : null}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={["#007AFF"]}
            tintColor="#007AFF"
          />
        }
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.listContainer}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f0f0f0",
  },
  listContainer: {
    flexGrow: 1,
  },
  header: {
    backgroundColor: "#fff",
    padding: 20,
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
    textAlign: "center",
    marginBottom: 20,
  },
  timeRangeTabs: {
    flexDirection: "row",
    backgroundColor: "#f0f0f0",
    borderRadius: 12,
    padding: 4,
    marginBottom: 16,
  },
  timeRangeTab: {
    flex: 1,
    paddingVertical: 8,
    alignItems: "center",
    borderRadius: 8,
  },
  activeTimeRangeTab: {
    backgroundColor: "#007AFF",
  },
  timeRangeTabText: {
    fontSize: 12,
    fontWeight: "600",
    color: "#666",
  },
  activeTimeRangeTabText: {
    color: "#fff",
  },
  currentPlayerRank: {
    backgroundColor: "#E3F2FD",
    padding: 12,
    borderRadius: 8,
    alignItems: "center",
  },
  currentPlayerRankText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#1976D2",
  },
  playerItem: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#fff",
    marginHorizontal: 20,
    marginVertical: 4,
    padding: 16,
    borderRadius: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  currentPlayerItem: {
    backgroundColor: "#E8F5E8",
    borderColor: "#34C759",
    borderWidth: 2,
  },
  topPlayerItem: {
    backgroundColor: "#FFF8E1",
    borderColor: "#FFD700",
    borderWidth: 1,
  },
  rankContainer: {
    width: 50,
    alignItems: "center",
  },
  rankText: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#666",
  },
  topRankText: {
    fontSize: 24,
  },
  currentPlayerRankText: {
    color: "#34C759",
  },
  playerInfo: {
    flex: 1,
    marginLeft: 12,
  },
  playerName: {
    fontSize: 16,
    fontWeight: "600",
    color: "#333",
    marginBottom: 4,
  },
  currentPlayerName: {
    color: "#34C759",
  },
  playerScore: {
    fontSize: 14,
    color: "#666",
  },
  avatarContainer: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: "#E0E0E0",
    alignItems: "center",
    justifyContent: "center",
  },
  avatar: {
    fontSize: 20,
  },
  emptyState: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    padding: 40,
  },
  emptyStateText: {
    fontSize: 64,
    marginBottom: 16,
  },
  emptyStateTitle: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 8,
  },
  emptyStateDescription: {
    fontSize: 16,
    color: "#666",
    textAlign: "center",
  },
});

export default LeaderboardScreen;
