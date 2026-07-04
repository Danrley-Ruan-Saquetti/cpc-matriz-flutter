import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/ticket.dart';
import 'package:cpc_matriz/data/repositories/sqlite/sqlite_row_mapper.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/data/services/sqlite_database_service.dart';

class SqliteTicketRepository implements TicketRepository {
  SqliteTicketRepository(this._service);

  final SqliteDatabaseService _service;

  static const List<String> _colunasData = ['criado_em', 'utilizado_em'];

  Ticket _mapToTicket(Map<String, dynamic> row) =>
      Ticket.fromMap(hydrateRow(row, _colunasData));

  Future<Ticket> _buscarPorId(int id) async {
    final db = await _service.database;
    final rows = await db.query(
      'tickets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return _mapToTicket(rows.first);
  }

  @override
  Future<List<Ticket>> listar() async {
    final db = await _service.database;
    final rows = await db.query('tickets', orderBy: 'criado_em DESC');

    return rows.map(_mapToTicket).toList();
  }

  @override
  Future<Ticket> criar(Ticket ticket) async {
    final db = await _service.database;
    final id = await db.insert('tickets', ticket.toParams());

    return _buscarPorId(id);
  }

  @override
  Future<Ticket> atualizarStatus(int id, StatusTicket status) async {
    final db = await _service.database;

    final utilizadoEm = status == StatusTicket.utilizado
        ? DateTime.now().toIso8601String()
        : null;

    await db.update(
      'tickets',
      {'status': status.valor, 'utilizado_em': utilizadoEm},
      where: 'id = ?',
      whereArgs: [id],
    );

    return _buscarPorId(id);
  }

  @override
  Future<void> remover(int id) async {
    final db = await _service.database;
    await db.delete('tickets', where: 'id = ?', whereArgs: [id]);
  }
}
