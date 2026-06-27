import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/ticket.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/viewmodels/base_viewmodel.dart';

class TicketsViewModel extends BaseViewModel {
  TicketsViewModel(this._repository);

  final TicketRepository _repository;

  List<Ticket> _todos = [];
  String _busca = '';
  StatusTicket? _statusFiltro;

  String get busca => _busca;
  StatusTicket? get statusFiltro => _statusFiltro;

  List<Ticket> get tickets {
    return _todos.where((t) {
      final correspondeBusca =
          _busca.isEmpty ||
          t.evento.toLowerCase().contains(_busca.toLowerCase()) ||
          t.participante.toLowerCase().contains(_busca.toLowerCase()) ||
          t.codigo.toLowerCase().contains(_busca.toLowerCase());

      final correspondeStatus =
          _statusFiltro == null || t.status == _statusFiltro;

      return correspondeBusca && correspondeStatus;
    }).toList();
  }

  bool get vazio => tickets.isEmpty;

  int get totalValidos =>
      _todos.where((ticket) => ticket.status == StatusTicket.valido).length;

  double get totalArrecadado => _todos
      .where((ticket) => ticket.status != StatusTicket.cancelado)
      .fold(0.0, (soma, t) => soma + t.valor);

  Future<void> carregar() async {
    await run(() async {
      _todos = await _repository.listar();
    });
  }

  void buscar(String termo) {
    _busca = termo;
    notifyListeners();
  }

  void filtrarPorStatus(StatusTicket? status) {
    _statusFiltro = status;
    notifyListeners();
  }

  Future<bool> alterarStatus(Ticket ticket, StatusTicket status) async {
    if (ticket.id == null) {
      return false;
    }

    return run(() async {
      await _repository.atualizarStatus(ticket.id!, status);
      _todos = await _repository.listar();
    });
  }

  Future<bool> remover(Ticket ticket) async {
    if (ticket.id == null) {
      return false;
    }

    return run(() async {
      await _repository.remover(ticket.id!);
      _todos = await _repository.listar();
    });
  }
}
