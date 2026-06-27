class DbConfig {
  const DbConfig._();

  static const String host = 'localhost';
  static const int port = 5432;
  static const String database = 'cpc_matriz';
  static const String username = 'postgres';
  static const String password = 'postgres';

  static const bool useSsl = false;
}
