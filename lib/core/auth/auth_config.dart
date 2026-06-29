class AuthConfig {
  // Users must create their own Google Cloud project + OAuth client ID
  // https://console.cloud.google.com/apis/credentials
  // Application type: Desktop app (for Windows) or Android (for mobile)
  static const String clientId = 'YOUR_CLIENT_ID';
  static const String scope = 'https://www.googleapis.com/auth/youtube';
  static const String deviceCodeUrl = 'https://oauth2.googleapis.com/device/code';
  static const String tokenUrl = 'https://oauth2.googleapis.com/token';
}
