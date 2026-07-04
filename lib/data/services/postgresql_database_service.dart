import 'package:cpc_matriz/core/config/db_config.dart';
import 'package:postgres/postgres.dart';

class PostgresDatabaseService {
  Connection? _connection;

  bool get isConnected => _connection?.isOpen ?? false;

  Future<Connection> _ensureConnection() async {
    final currentConnection = _connection;

    if (currentConnection != null && currentConnection.isOpen) {
      return currentConnection;
    }

    final newConnection = await Connection.open(
      Endpoint(
        host: DbConfig.host,
        port: DbConfig.port,
        database: DbConfig.database,
        username: DbConfig.username,
        password: DbConfig.password,
      ),
      settings: ConnectionSettings(
        sslMode: DbConfig.useSsl ? SslMode.require : SslMode.disable,
        connectTimeout: const Duration(seconds: 10),
      ),
    );

    _connection = newConnection;

    return newConnection;
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    final conn = await _ensureConnection();

    final result = await conn.execute(
      Sql.named(sql),
      parameters: parameters ?? const {},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>?> execute(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    final conn = await _ensureConnection();

    final result = await conn.execute(
      Sql.named(sql),
      parameters: parameters ?? const {},
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first.toColumnMap();
  }

  Future<T> runTransaction<T>(Future<T> Function(TxSession tx) action) async {
    final conn = await _ensureConnection();
    return conn.runTx(action);
  }

  Future<void> dispose() async {
    await _connection?.close();
    _connection = null;
  }
}
