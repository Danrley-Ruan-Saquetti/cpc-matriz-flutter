import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/ticket.dart';

abstract interface class TicketRepository {
  Future<List<Ticket>> listar();
  Future<Ticket> criar(Ticket ticket);
  Future<Ticket> atualizarStatus(int id, StatusTicket status);
  Future<void> remover(int id);
}
