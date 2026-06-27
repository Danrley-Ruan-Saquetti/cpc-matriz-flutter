import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/ticket.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/viewmodels/base_viewmodel.dart';
import 'package:uuid/uuid.dart';

class TicketFormViewModel extends BaseViewModel {
  TicketFormViewModel(this._repository);

  final TicketRepository _repository;
  static const _uuid = Uuid();

  Ticket? ultimoGerado;

  String _gerarCodigo() {
    final hex = _uuid.v4().replaceAll('-', '').substring(0, 8).toUpperCase();
    return 'TKT-$hex';
  }

  Future<bool> gerar({
    required String evento,
    required String participante,
    required double valor,
  }) async {
    final ticket = Ticket(
      codigo: _gerarCodigo(),
      evento: evento.trim(),
      participante: participante.trim(),
      valor: valor,
      status: StatusTicket.valido,
    );

    return run(() async {
      ultimoGerado = await _repository.criar(ticket);
    });
  }
}
