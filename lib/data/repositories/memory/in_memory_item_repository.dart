import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_store.dart';

class InMemoryItemRepository implements ItemRepository {
  InMemoryItemRepository(this._store);

  final InMemoryStore _store;

  @override
  Future<List<Item>> listar() async {
    final lista = [..._store.itens]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    return lista;
  }

  @override
  Future<Item?> buscarPorId(int id) async {
    for (final item in _store.itens) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  Future<Item> criar(Item item) async {
    final novo = Item(
      id: _store.proximoItemId,
      nome: item.nome,
      categoria: item.categoria,
      unidade: item.unidade,
      quantidade: item.quantidade,
      quantidadeMinima: item.quantidadeMinima,
      descricao: item.descricao,
      criadoEm: DateTime.now(),
    );

    _store.itens.add(novo);

    return novo;
  }

  @override
  Future<Item> atualizar(Item item) async {
    final indice = _store.itens.indexWhere((i) => i.id == item.id);

    if (indice == -1) {
      throw Exception('Item nao encontrado.');
    }

    final atualizado = Item(
      id: item.id,
      nome: item.nome,
      categoria: item.categoria,
      unidade: item.unidade,
      quantidade: item.quantidade,
      quantidadeMinima: item.quantidadeMinima,
      descricao: item.descricao,
      criadoEm: _store.itens[indice].criadoEm,
    );

    _store.itens[indice] = atualizado;

    return atualizado;
  }

  @override
  Future<void> remover(int id) async {
    _store.itens.removeWhere((i) => i.id == id);
    _store.movimentacoes.removeWhere((m) => m.itemId == id);
  }
}
