// Типы для навигации

export type RootStackParamList = {
  Main: undefined;
  Game: undefined;
  Profile: undefined;
};

export type TabParamList = {
  Home: undefined;
  Shop: undefined;
  Leaderboard: undefined;
  Settings: undefined;
};

declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}
