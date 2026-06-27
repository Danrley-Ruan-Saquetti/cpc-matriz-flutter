import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_item_repository.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_store.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_ticket_repository.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/postgres/postgres_item_repository.dart';
import 'package:cpc_matriz/data/repositories/postgres/postgres_movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/postgres/postgres_ticket_repository.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/data/services/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

List<SingleChildWidget> buildPersistenceProviders() {
  if (kIsWeb) {
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

  return [
    Provider<DatabaseService>(
      create: (_) => DatabaseService(),
      dispose: (_, db) => db.dispose(),
    ),
    ProxyProvider<DatabaseService, ItemRepository>(
      update: (_, db, _) => PostgresItemRepository(db),
    ),
    ProxyProvider<DatabaseService, MovimentacaoRepository>(
      update: (_, db, _) => PostgresMovimentacaoRepository(db),
    ),
    ProxyProvider<DatabaseService, TicketRepository>(
      update: (_, db, _) => PostgresTicketRepository(db),
    ),
  ];
}
