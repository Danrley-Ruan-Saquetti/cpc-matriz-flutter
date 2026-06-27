import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/models/movimentacao.dart';
import 'package:cpc_matriz/data/repositories/memory/in_memory_store.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';

class InMemoryMovimentacaoRepository implements MovimentacaoRepository {
  InMemoryMovimentacaoRepository(this._store);

  final InMemoryStore _store;

  Movimentacao _comItemNome(Movimentacao m) {
    String? nome;

    for (final i in _store.itens) {
      if (i.id == m.itemId) {
        nome = i.nome;
        break;
      }
    }

    return Movimentacao(
      id: m.id,
      itemId: m.itemId,
      tipo: m.tipo,
      quantidade: m.quantidade,
      responsavel: m.responsavel,
      observacao: m.observacao,
      criadoEm: m.criadoEm,
      itemNome: nome ?? 'Item ${m.itemId}',
    );
  }

  @override
  Future<List<Movimentacao>> listar() async {
    final lista = _store.movimentacoes.map(_comItemNome).toList()
      ..sort(
        (a, b) =>
            (b.criadoEm ?? DateTime(0)).compareTo(a.criadoEm ?? DateTime(0)),
      );
    return lista;
  }

  @override
  Future<List<Movimentacao>> listarPorItem(int itemId) async {
    final todas = await listar();

    return todas.where((m) => m.itemId == itemId).toList();
  }

  @override
  Future<Movimentacao> registrar(Movimentacao mov) async {
    final indice = _store.itens.indexWhere((i) => i.id == mov.itemId);

    if (indice != -1) {
      final Item item = _store.itens[indice];
      final delta = mov.tipo == TipoMovimentacao.entrada
          ? mov.quantidade
          : -mov.quantidade;

      _store.itens[indice] = item.copyWith(quantidade: item.quantidade + delta);
    }

    final registrada = Movimentacao(
      id: _store.proximaMovId,
      itemId: mov.itemId,
      tipo: mov.tipo,
      quantidade: mov.quantidade,
      responsavel: mov.responsavel,
      observacao: mov.observacao,
      criadoEm: DateTime.now(),
    );

    _store.movimentacoes.add(registrada);

    return _comItemNome(registrada);
  }
}
