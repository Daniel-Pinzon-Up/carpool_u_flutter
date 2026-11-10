class AppConfig {
  const AppConfig._();

  static const bool localMode = bool.fromEnvironment(
    'LOCAL_MODE',
    defaultValue: true,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
}
