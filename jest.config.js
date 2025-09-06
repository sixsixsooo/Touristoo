module.exports = {
  preset: "react-native",
  setupFilesAfterEnv: ["<rootDir>/jest.setup.js"],
  testPathIgnorePatterns: ["/node_modules/", "/backend/"],
  transformIgnorePatterns: [
    "node_modules/(?!(react-native|@react-native|expo|@expo|@react-navigation|@reduxjs|react-redux)/)",
  ],
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json"],
  testMatch: ["**/__tests__/**/*.(ts|tsx|js)", "**/*.(test|spec).(ts|tsx|js)"],
  collectCoverageFrom: [
    "src/**/*.{ts,tsx}",
    "!src/**/*.d.ts",
    "!src/**/__tests__/**",
  ],
};
