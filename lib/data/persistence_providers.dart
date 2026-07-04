import 'package:cpc_matriz/core/config/persistence_config.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_item_repository.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_store.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_ticket_repository.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/postgres/postgres_item_repository.dart';
import 'package:cpc_matriz/data/repositories/postgres/postgres_movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/postgres/postgres_ticket_repository.dart';
import 'package:cpc_matriz/data/repositories/sqlite/sqlite_item_repository.dart';
import 'package:cpc_matriz/data/repositories/sqlite/sqlite_movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/sqlite/sqlite_ticket_repository.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/data/services/postgresql_database_service.dart';
import 'package:cpc_matriz/data/services/sqlite_database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

List<SingleChildWidget> buildPersistenceProviders() {
  if (kIsWeb) {
    return _memoryProviders();
  }

  return switch (PersistenceConfig.source) {
    PersistenceSource.memory => _memoryProviders(),
    PersistenceSource.sqlite => _sqlitePersistenceProviders(),
    PersistenceSource.postgres => _postgresProviders(),
  };
}

List<SingleChildWidget> _memoryProviders() {
  return [
    Provider<InMemoryStore>(create: (_) => InMemoryStore()),
    ProxyProvider<InMemoryStore, ItemRepository>(
      update: (_, store, _) => InMemoryItemRepository(store),
    ),
    ProxyProvider<InMemoryStore, MovimentacaoRepository>(
      update: (_, store, _) => InMemoryMovimentacaoRepository(store),
    ),
    ProxyProvider<InMemoryStore, TicketRepository>(
      update: (_, store, _) => InMemoryTicketRepository(store),
    ),
  ];
}

List<SingleChildWidget> _sqlitePersistenceProviders() {
  return [
    Provider<SqliteDatabaseService>(
      create: (_) => SqliteDatabaseService(),
      dispose: (_, service) => service.dispose(),
    ),
    ProxyProvider<SqliteDatabaseService, ItemRepository>(
      update: (_, service, _) => SqliteItemRepository(service),
    ),
    ProxyProvider<SqliteDatabaseService, MovimentacaoRepository>(
      update: (_, service, _) => SqliteMovimentacaoRepository(service),
    ),
    ProxyProvider<SqliteDatabaseService, TicketRepository>(
      update: (_, service, _) => SqliteTicketRepository(service),
    ),
  ];
}

List<SingleChildWidget> _postgresProviders() {
  return [
    Provider<PostgresDatabaseService>(
      create: (_) => PostgresDatabaseService(),
      dispose: (_, db) => db.dispose(),
    ),
    ProxyProvider<PostgresDatabaseService, ItemRepository>(
      update: (_, db, _) => PostgresItemRepository(db),
    ),
    ProxyProvider<PostgresDatabaseService, MovimentacaoRepository>(
      update: (_, db, _) => PostgresMovimentacaoRepository(db),
    ),
    ProxyProvider<PostgresDatabaseService, TicketRepository>(
      update: (_, db, _) => PostgresTicketRepository(db),
    ),
  ];
}
