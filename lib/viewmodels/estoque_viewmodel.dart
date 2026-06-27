import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/viewmodels/base_viewmodel.dart';

class EstoqueViewModel extends BaseViewModel {
  EstoqueViewModel(this._repository);

  final ItemRepository _repository;

  List<Item> _todos = [];
  String _busca = '';
  String? _categoriaSelecionada;
  bool _apenasEstoqueBaixo = false;

  String get busca => _busca;
  String? get categoriaSelecionada => _categoriaSelecionada;
  bool get apenasEstoqueBaixo => _apenasEstoqueBaixo;

  List<String> get categorias =>
      _todos.map((i) => i.categoria).toSet().toList()..sort();

  List<Item> get itens {
    return _todos.where((item) {
      final correspondeBusca =
          _busca.isEmpty ||
          item.nome.toLowerCase().contains(_busca.toLowerCase()) ||
          item.categoria.toLowerCase().contains(_busca.toLowerCase());

      final correspondeCategoria =
          _categoriaSelecionada == null ||
          item.categoria == _categoriaSelecionada;

      final correspondeEstoque = !_apenasEstoqueBaixo || item.estoqueBaixo;

      return correspondeBusca && correspondeCategoria && correspondeEstoque;
    }).toList();
  }

  bool get vazio => itens.isEmpty;

  Future<void> carregar() async {
    await run(() async {
      _todos = await _repository.listar();
    });
  }

  void buscar(String termo) {
    _busca = termo;
    notifyListeners();
  }

  void filtrarPorCategoria(String? categoria) {
    _categoriaSelecionada = categoria;
    notifyListeners();
  }

  void alternarEstoqueBaixo(bool valor) {
    _apenasEstoqueBaixo = valor;
    notifyListeners();
  }

  void limparFiltros() {
    _busca = '';
    _categoriaSelecionada = null;
    _apenasEstoqueBaixo = false;
    notifyListeners();
  }

  Future<bool> remover(Item item) async {
    if (item.id == null) {
      return false;
    }

    final ok = await run(() async {
      await _repository.remover(item.id!);

      _todos = await _repository.listar();
    });

    return ok;
  }
}
