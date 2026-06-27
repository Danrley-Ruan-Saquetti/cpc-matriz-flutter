import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/models/movimentacao.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/viewmodels/base_viewmodel.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel(
    this._itemRepository,
    this._movimentacaoRepository,
    this._ticketRepository,
  );

  final ItemRepository _itemRepository;
  final MovimentacaoRepository _movimentacaoRepository;
  final TicketRepository _ticketRepository;

  List<Item> _itens = [];
  List<Movimentacao> _movimentacoes = [];

  int get totalItens => _itens.length;
  int get totalUnidades => _itens.fold(0, (soma, i) => soma + i.quantidade);

  List<Item> get itensEstoqueBaixo =>
      _itens.where((i) => i.estoqueBaixo).toList();
  int get totalEstoqueBaixo => itensEstoqueBaixo.length;

  int _ticketsValidos = 0;
  double _totalArrecadado = 0;
  int get ticketsValidos => _ticketsValidos;
  double get totalArrecadado => _totalArrecadado;

  int get totalMovimentacoes => _movimentacoes.length;

  List<Movimentacao> get movimentacoesRecentes =>
      _movimentacoes.take(5).toList();

  Future<void> carregar() async {
    await run(() async {
      _itens = await _itemRepository.listar();
      _movimentacoes = await _movimentacaoRepository.listar();
      final tickets = await _ticketRepository.listar();

      _ticketsValidos = tickets
          .where((t) => t.status == StatusTicket.valido)
          .length;

      _totalArrecadado = tickets
          .where((t) => t.status != StatusTicket.cancelado)
          .fold(0.0, (soma, t) => soma + t.valor);
    });
  }
}
