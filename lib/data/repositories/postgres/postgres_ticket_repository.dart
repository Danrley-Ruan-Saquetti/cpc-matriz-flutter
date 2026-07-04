import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/ticket.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/data/services/postgresql_database_service.dart';

class PostgresTicketRepository implements TicketRepository {
  PostgresTicketRepository(this._db);

  final PostgresDatabaseService _db;

  @override
  Future<List<Ticket>> listar() async {
    final linhas = await _db.query(
      'SELECT * FROM tickets ORDER BY criado_em DESC',
    );

    return linhas.map(Ticket.fromMap).toList();
  }

  @override
  Future<Ticket> criar(Ticket ticket) async {
    final linha = await _db.execute('''
      INSERT INTO tickets (codigo, evento, participante, valor, status)
      VALUES (@codigo, @evento, @participante, @valor, @status)
      RETURNING *
      ''', parameters: ticket.toParams());

    return Ticket.fromMap(linha!);
  }

  @override
  Future<Ticket> atualizarStatus(int id, StatusTicket status) async {
    final linha = await _db.execute(
      '''
      UPDATE tickets
         SET status = @status,
             utilizado_em = CASE WHEN @status = 'utilizado' THEN NOW() ELSE NULL END
       WHERE id = @id
      RETURNING *
      ''',
      parameters: {'id': id, 'status': status.valor},
    );

    return Ticket.fromMap(linha!);
  }

  @override
  Future<void> remover(int id) async {
    await _db.execute(
      'DELETE FROM tickets WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
