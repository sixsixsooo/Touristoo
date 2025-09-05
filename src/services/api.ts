import axios, { AxiosInstance, AxiosResponse } from "axios";
import {
  ApiResponse,
  LoginRequest,
  LoginResponse,
  LeaderboardRequest,
  SyncRequest,
  SyncResponse,
  Player,
  LeaderboardEntry,
} from "@/types";

class ApiService {
  private api: AxiosInstance;
  private baseURL: string;

  constructor() {
    this.baseURL = __DEV__
      ? "http://localhost:3000/api"
      : "https://api.touristoo.runner.com/api";

    this.api = axios.create({
      baseURL: this.baseURL,
      timeout: 10000,
      headers: {
        "Content-Type": "application/json",
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor для добавления токена
    this.api.interceptors.request.use(
      (config) => {
        const token = this.getAuthToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor для обработки ошибок
    this.api.interceptors.response.use(
      (response) => response,
      async (error) => {
        if (error.response?.status === 401) {
          // Токен истек, попробуем обновить
          await this.refreshToken();
        }
        return Promise.reject(error);
      }
    );
  }

  private getAuthToken(): string | null {
    // В реальном приложении получать из secure storage
    return null;
  }

  private async refreshToken(): Promise<void> {
    // Логика обновления токена
    console.log("Refreshing token...");
  }

  // Auth endpoints
  async login(credentials: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    try {
      const response: AxiosResponse<ApiResponse<LoginResponse>> =
        await this.api.post("/auth/login", credentials);
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  async register(
    credentials: LoginRequest
  ): Promise<ApiResponse<LoginResponse>> {
    try {
      const response: AxiosResponse<ApiResponse<LoginResponse>> =
        await this.api.post("/auth/register", credentials);
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  async logout(): Promise<ApiResponse<void>> {
    try {
      const response: AxiosResponse<ApiResponse<void>> = await this.api.post(
        "/auth/logout"
      );
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  // Player endpoints
  async getPlayerProfile(): Promise<ApiResponse<Player>> {
    try {
      const response: AxiosResponse<ApiResponse<Player>> = await this.api.get(
        "/player/profile"
      );
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  async updatePlayerProfile(
    updates: Partial<Player>
  ): Promise<ApiResponse<Player>> {
    try {
      const response: AxiosResponse<ApiResponse<Player>> = await this.api.patch(
        "/player/profile",
        updates
      );
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  // Game data sync
  async syncGameData(
    syncData: SyncRequest
  ): Promise<ApiResponse<SyncResponse>> {
    try {
      const response: AxiosResponse<ApiResponse<SyncResponse>> =
        await this.api.post("/game/sync", syncData);
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  // Leaderboard endpoints
  async getLeaderboard(
    params?: LeaderboardRequest
  ): Promise<ApiResponse<LeaderboardEntry[]>> {
    try {
      const response: AxiosResponse<ApiResponse<LeaderboardEntry[]>> =
        await this.api.get("/leaderboard", { params });
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  async submitScore(score: number): Promise<ApiResponse<void>> {
    try {
      const response: AxiosResponse<ApiResponse<void>> = await this.api.post(
        "/leaderboard/submit",
        { score }
      );
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  // Assets endpoints
  async getAssetUrl(assetPath: string): Promise<string> {
    return `${this.baseURL}/assets/${assetPath}`;
  }

  private handleError(error: any): ApiResponse<any> {
    console.error("API Error:", error);

    if (error.response) {
      return {
        success: false,
        error: error.response.data?.message || "Server error",
        data: null,
      };
    } else if (error.request) {
      return {
        success: false,
        error: "Network error",
        data: null,
      };
    } else {
      return {
        success: false,
        error: "Unknown error",
        data: null,
      };
    }
  }
}

export const apiService = new ApiService();
export default apiService;
