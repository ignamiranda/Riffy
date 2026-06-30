class AuthConfig {
  // Create your own Google Cloud project + OAuth client ID:
  // https://console.cloud.google.com/apis/credentials
  // Application type: Desktop app (for Windows) or Android (for mobile)
  //
  // For public clients (Desktop/Android), the client ID is a public identifier,
  // not a secret — it's baked into the binary regardless.
  static const String clientId = '426136176683-420i6dlou5502oqt0fnkooa2visu74pc.apps.googleusercontent.com';

  static const String scope = 'https://www.googleapis.com/auth/youtube';
  static const String deviceCodeUrl = 'https://oauth2.googleapis.com/device/code';
  static const String tokenUrl = 'https://oauth2.googleapis.com/token';
}
