import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/movimentacao.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/viewmodels/base_viewmodel.dart';

class HistoricoViewModel extends BaseViewModel {
  HistoricoViewModel(this._repository);

  final MovimentacaoRepository _repository;

  List<Movimentacao> _todas = [];
  String _busca = '';
  TipoMovimentacao? _tipoFiltro;

  String get busca => _busca;
  TipoMovimentacao? get tipoFiltro => _tipoFiltro;

  List<Movimentacao> get movimentacoes {
    return _todas.where((m) {
      final correspondeBusca =
          _busca.isEmpty ||
          (m.itemNome?.toLowerCase().contains(_busca.toLowerCase()) ?? false) ||
          m.responsavel.toLowerCase().contains(_busca.toLowerCase());

      final correspondeTipo = _tipoFiltro == null || m.tipo == _tipoFiltro;

      return correspondeBusca && correspondeTipo;
    }).toList();
  }

  bool get vazio => movimentacoes.isEmpty;

  int get totalEntradas =>
      _todas.where((m) => m.tipo == TipoMovimentacao.entrada).length;
  int get totalSaidas =>
      _todas.where((m) => m.tipo == TipoMovimentacao.saida).length;

  Future<void> carregar() async {
    await run(() async {
      _todas = await _repository.listar();
    });
  }

  void buscar(String termo) {
    _busca = termo;
    notifyListeners();
  }

  void filtrarPorTipo(TipoMovimentacao? tipo) {
    _tipoFiltro = tipo;
    notifyListeners();
  }
}
