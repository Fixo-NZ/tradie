class EchoConfig {
  // Laravel Echo/Reverb Configuration
  static const String appKey = String.fromEnvironment(
    'REVERB_APP_KEY',
    defaultValue: 'o3kuufyyhwwte7mwu5fo',
  );
  
  static const String appId = String.fromEnvironment(
    'REVERB_APP_ID',
    defaultValue: 'local',
  );
  
  static const String appSecret = String.fromEnvironment(
    'REVERB_APP_SECRET',
    defaultValue: 'local-secret',
  );
  
  static const String host = String.fromEnvironment(
    'REVERB_HOST',
    defaultValue: 'localhost',
  );
  
  static const int port = int.fromEnvironment(
    'REVERB_PORT',
    defaultValue: 8080,
  );
  
  static const String scheme = String.fromEnvironment(
    'REVERB_SCHEME',
    defaultValue: 'http',
  );
  
  // Development vs Production configuration
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  
  // Dynamic configuration based on environment
  static String get wsUrl => isProduction 
      ? 'wss://your-domain.com:443/app/$appKey'
      : '$scheme://$host:$port/app/$appKey';
      
  static Map<String, String> get authHeaders => {
    'Authorization': 'Bearer your-auth-token', // Add your auth token here
  };
}