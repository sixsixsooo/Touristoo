import "react-native-gesture-handler/jestSetup";

// Mock expo modules
jest.mock("expo-gl", () => ({
  GLView: "GLView",
}));

jest.mock("expo-three", () => ({
  Renderer: jest.fn(),
}));

jest.mock("expo-sqlite", () => ({
  openDatabase: jest.fn(() => ({
    transaction: jest.fn(),
    readTransaction: jest.fn(),
    close: jest.fn(),
  })),
}));

jest.mock("@react-native-async-storage/async-storage", () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
}));

// Mock three.js
jest.mock("three", () => ({
  Scene: jest.fn(),
  PerspectiveCamera: jest.fn(),
  WebGLRenderer: jest.fn(),
  AmbientLight: jest.fn(),
  DirectionalLight: jest.fn(),
  BoxGeometry: jest.fn(),
  MeshLambertMaterial: jest.fn(),
  Mesh: jest.fn(),
  PlaneGeometry: jest.fn(),
  ConeGeometry: jest.fn(),
  CylinderGeometry: jest.fn(),
  SphereGeometry: jest.fn(),
  Color: jest.fn(),
  Fog: jest.fn(),
  PCFSoftShadowMap: "PCFSoftShadowMap",
}));

// Silence the warning: Animated: `useNativeDriver` is not supported
jest.mock("react-native/Libraries/Animated/NativeAnimatedHelper");
