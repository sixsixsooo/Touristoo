import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
  TextInput,
  Alert,
  ScrollView,
} from "react-native";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "@/store";
import { apiService } from "@/services/api";

const ProfileScreen: React.FC = () => {
  const dispatch = useDispatch();
  const { currentPlayer, isAuthenticated, isLoading } = useSelector(
    (state: RootState) => state.player
  );
  const [isLoginMode, setIsLoginMode] = useState(true);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");

  const handleGuestLogin = async () => {
    try {
      dispatch({ type: "player/setLoading", payload: true });

      // Создаем гостевого игрока
      const guestPlayer = {
        id: `guest_${Date.now()}`,
        name: `Гость ${Math.floor(Math.random() * 1000)}`,
        email: undefined,
        avatar: undefined,
        totalScore: 0,
        level: 1,
        coins: 0,
        skins: ["1"], // Базовый скин
        currentSkin: "1",
        isGuest: true,
        lastSyncAt: undefined,
      };

      dispatch({ type: "player/loginSuccess", payload: guestPlayer });
      Alert.alert("Успех", "Вход выполнен как гость");
    } catch (error) {
      console.error("Guest login failed:", error);
      Alert.alert("Ошибка", "Не удалось войти как гость");
    } finally {
      dispatch({ type: "player/setLoading", payload: false });
    }
  };

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert("Ошибка", "Заполните все поля");
      return;
    }

    try {
      dispatch({ type: "player/setLoading", payload: true });

      const response = await apiService.login({
        email,
        password,
      });

      if (response.success && response.data) {
        dispatch({
          type: "player/loginSuccess",
          payload: response.data.player,
        });
        Alert.alert("Успех", "Вход выполнен успешно");
        setEmail("");
        setPassword("");
      } else {
        Alert.alert("Ошибка", response.error || "Не удалось войти");
      }
    } catch (error) {
      console.error("Login failed:", error);
      Alert.alert("Ошибка", "Ошибка сети");
    } finally {
      dispatch({ type: "player/setLoading", payload: false });
    }
  };

  const handleRegister = async () => {
    if (!email || !password || !name) {
      Alert.alert("Ошибка", "Заполните все поля");
      return;
    }

    try {
      dispatch({ type: "player/setLoading", payload: true });

      const response = await apiService.register({
        email,
        password,
        name,
      });

      if (response.success && response.data) {
        dispatch({
          type: "player/loginSuccess",
          payload: response.data.player,
        });
        Alert.alert("Успех", "Регистрация выполнена успешно");
        setEmail("");
        setPassword("");
        setName("");
      } else {
        Alert.alert(
          "Ошибка",
          response.error || "Не удалось зарегистрироваться"
        );
      }
    } catch (error) {
      console.error("Registration failed:", error);
      Alert.alert("Ошибка", "Ошибка сети");
    } finally {
      dispatch({ type: "player/setLoading", payload: false });
    }
  };

  const handleLogout = () => {
    Alert.alert("Выход", "Вы уверены, что хотите выйти?", [
      { text: "Отмена", style: "cancel" },
      {
        text: "Выйти",
        style: "destructive",
        onPress: () => {
          dispatch({ type: "player/logout" });
          Alert.alert("Успех", "Вы вышли из аккаунта");
        },
      },
    ]);
  };

  const handleYandexLogin = async () => {
    // В реальном приложении здесь будет интеграция с Yandex ID
    Alert.alert(
      "Yandex ID",
      "Интеграция с Yandex ID будет добавлена в следующих версиях",
      [{ text: "OK" }]
    );
  };

  const renderLoginForm = () => (
    <View style={styles.form}>
      <Text style={styles.formTitle}>
        {isLoginMode ? "Вход в аккаунт" : "Регистрация"}
      </Text>

      {!isLoginMode && (
        <TextInput
          style={styles.input}
          placeholder="Имя"
          value={name}
          onChangeText={setName}
          autoCapitalize="words"
        />
      )}

      <TextInput
        style={styles.input}
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
      />

      <TextInput
        style={styles.input}
        placeholder="Пароль"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />

      <TouchableOpacity
        style={styles.primaryButton}
        onPress={isLoginMode ? handleLogin : handleRegister}
        disabled={isLoading}
      >
        <Text style={styles.primaryButtonText}>
          {isLoading
            ? "Загрузка..."
            : isLoginMode
            ? "Войти"
            : "Зарегистрироваться"}
        </Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={styles.linkButton}
        onPress={() => setIsLoginMode(!isLoginMode)}
      >
        <Text style={styles.linkButtonText}>
          {isLoginMode
            ? "Нет аккаунта? Зарегистрироваться"
            : "Есть аккаунт? Войти"}
        </Text>
      </TouchableOpacity>

      <View style={styles.divider}>
        <View style={styles.dividerLine} />
        <Text style={styles.dividerText}>или</Text>
        <View style={styles.dividerLine} />
      </View>

      <TouchableOpacity style={styles.yandexButton} onPress={handleYandexLogin}>
        <Text style={styles.yandexButtonText}>Войти через Yandex ID</Text>
      </TouchableOpacity>
    </View>
  );

  const renderProfileInfo = () => (
    <View style={styles.profileInfo}>
      <View style={styles.avatarContainer}>
        <Text style={styles.avatarText}>
          {currentPlayer?.name?.charAt(0).toUpperCase() || "👤"}
        </Text>
      </View>

      <Text style={styles.playerName}>{currentPlayer?.name}</Text>
      <Text style={styles.playerEmail}>{currentPlayer?.email}</Text>

      <View style={styles.statsContainer}>
        <View style={styles.statItem}>
          <Text style={styles.statValue}>
            {currentPlayer?.totalScore?.toLocaleString() || 0}
          </Text>
          <Text style={styles.statLabel}>Общий счет</Text>
        </View>
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{currentPlayer?.level || 1}</Text>
          <Text style={styles.statLabel}>Уровень</Text>
        </View>
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{currentPlayer?.coins || 0}</Text>
          <Text style={styles.statLabel}>Монеты</Text>
        </View>
      </View>

      {currentPlayer?.isGuest && (
        <View style={styles.guestWarning}>
          <Text style={styles.guestWarningText}>
            ⚠️ Вы играете как гость. Войдите в аккаунт для синхронизации
            прогресса.
          </Text>
        </View>
      )}

      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <Text style={styles.logoutButtonText}>Выйти из аккаунта</Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <Text style={styles.title}>Профиль</Text>
        </View>

        {isAuthenticated && currentPlayer
          ? renderProfileInfo()
          : renderLoginForm()}

        {!isAuthenticated && (
          <View style={styles.guestSection}>
            <Text style={styles.guestTitle}>Или играйте как гость</Text>
            <Text style={styles.guestDescription}>
              Начните играть сразу без регистрации. Прогресс будет сохранен
              локально.
            </Text>
            <TouchableOpacity
              style={styles.guestButton}
              onPress={handleGuestLogin}
              disabled={isLoading}
            >
              <Text style={styles.guestButtonText}>
                {isLoading ? "Загрузка..." : "Играть как гость"}
              </Text>
            </TouchableOpacity>
          </View>
        )}
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
  form: {
    backgroundColor: "#fff",
    margin: 20,
    padding: 20,
    borderRadius: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  formTitle: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#333",
    textAlign: "center",
    marginBottom: 20,
  },
  input: {
    borderWidth: 1,
    borderColor: "#E0E0E0",
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    marginBottom: 16,
    backgroundColor: "#fff",
  },
  primaryButton: {
    backgroundColor: "#007AFF",
    borderRadius: 8,
    padding: 16,
    alignItems: "center",
    marginBottom: 12,
  },
  primaryButtonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
  linkButton: {
    alignItems: "center",
    padding: 12,
  },
  linkButtonText: {
    color: "#007AFF",
    fontSize: 16,
  },
  divider: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 20,
  },
  dividerLine: {
    flex: 1,
    height: 1,
    backgroundColor: "#E0E0E0",
  },
  dividerText: {
    marginHorizontal: 16,
    color: "#666",
    fontSize: 14,
  },
  yandexButton: {
    backgroundColor: "#FF0000",
    borderRadius: 8,
    padding: 16,
    alignItems: "center",
  },
  yandexButtonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
  profileInfo: {
    backgroundColor: "#fff",
    margin: 20,
    padding: 20,
    borderRadius: 12,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  avatarContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: "#007AFF",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 16,
  },
  avatarText: {
    fontSize: 32,
    fontWeight: "bold",
    color: "#fff",
  },
  playerName: {
    fontSize: 24,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 8,
  },
  playerEmail: {
    fontSize: 16,
    color: "#666",
    marginBottom: 20,
  },
  statsContainer: {
    flexDirection: "row",
    justifyContent: "space-around",
    width: "100%",
    marginBottom: 20,
  },
  statItem: {
    alignItems: "center",
  },
  statValue: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#007AFF",
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 12,
    color: "#666",
  },
  guestWarning: {
    backgroundColor: "#FFF3CD",
    padding: 12,
    borderRadius: 8,
    marginBottom: 20,
    width: "100%",
  },
  guestWarningText: {
    fontSize: 14,
    color: "#856404",
    textAlign: "center",
  },
  logoutButton: {
    backgroundColor: "#ff6b6b",
    borderRadius: 8,
    padding: 16,
    alignItems: "center",
    width: "100%",
  },
  logoutButtonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
  guestSection: {
    backgroundColor: "#fff",
    margin: 20,
    padding: 20,
    borderRadius: 12,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  guestTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 8,
  },
  guestDescription: {
    fontSize: 14,
    color: "#666",
    textAlign: "center",
    marginBottom: 20,
  },
  guestButton: {
    backgroundColor: "#34C759",
    borderRadius: 8,
    padding: 16,
    alignItems: "center",
    width: "100%",
  },
  guestButtonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
});

export default ProfileScreen;
