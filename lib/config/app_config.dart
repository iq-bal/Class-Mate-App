class AppConfig {
  static const String server = "192.168.31.229";
  static const String baseUrl = 'http://$server:3001/api/v1/auth';
  static const String mainServerBaseUrl = 'http://$server:4000';
  static const String mainNormalBaseUrl = 'http://$server:4000/api/v1';
  static const String graphqlServer = 'http://$server:4001/graphql';
  static const String aiServer = 'http://$server:3000';
  static const String socketBaseUrl = 'http://$server:4002';
  static const int timeoutDuration = 30;
}