import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/ticket.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_store.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';

class InMemoryTicketRepository implements TicketRepository {
  InMemoryTicketRepository(this._store);

  final InMemoryStore _store;

  @override
  Future<List<Ticket>> listar() async {
    final lista = [..._store.tickets]
      ..sort(
        (a, b) =>
            (b.criadoEm ?? DateTime(0)).compareTo(a.criadoEm ?? DateTime(0)),
      );

    return lista;
  }

  @override
  Future<Ticket> criar(Ticket ticket) async {
    final novo = Ticket(
      id: _store.proximoTicketId,
      codigo: ticket.codigo,
      evento: ticket.evento,
      participante: ticket.participante,
      valor: ticket.valor,
      status: ticket.status,
      criadoEm: DateTime.now(),
    );

    _store.tickets.add(novo);

    return novo;
  }

  @override
  Future<Ticket> atualizarStatus(int id, StatusTicket status) async {
    final indice = _store.tickets.indexWhere((ticket) => ticket.id == id);

    if (indice == -1) {
      throw Exception('Ticket nao encontrado.');
    }

    final atual = _store.tickets[indice];

    final atualizado = Ticket(
      id: atual.id,
      codigo: atual.codigo,
      evento: atual.evento,
      participante: atual.participante,
      valor: atual.valor,
      status: status,
      criadoEm: atual.criadoEm,
      utilizadoEm: status == StatusTicket.utilizado ? DateTime.now() : null,
    );

    _store.tickets[indice] = atualizado;

    return atualizado;
  }

  @override
  Future<void> remover(int id) async {
    _store.tickets.removeWhere((ticket) => ticket.id == id);
  }
}
