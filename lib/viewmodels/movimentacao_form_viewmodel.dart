import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/models/movimentacao.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/viewmodels/base_viewmodel.dart';

class MovimentacaoFormViewModel extends BaseViewModel {
  MovimentacaoFormViewModel(
    this._itemRepository,
    this._movimentacaoRepository, {
    this.itemInicialId,
    this.tipoInicial = TipoMovimentacao.entrada,
  });

  final ItemRepository _itemRepository;
  final MovimentacaoRepository _movimentacaoRepository;
  final int? itemInicialId;
  final TipoMovimentacao tipoInicial;

  List<Item> _itens = [];
  List<Item> get itens => _itens;

  Movimentacao? ultimaRegistrada;

  Future<void> carregarItens() async {
    await run(() async {
      _itens = await _itemRepository.listar();
    });
  }

  Future<bool> registrar({
    required int itemId,
    required TipoMovimentacao tipo,
    required int quantidade,
    required String responsavel,
    String? observacao,
  }) async {
    final item = _itemPorId(itemId);

    if (item == null) {
      setError('Item nao encontrado.');
      return false;
    }

    if (tipo == TipoMovimentacao.saida && quantidade > item.quantidade) {
      setError(
        'Estoque insuficiente. Disponivel: ${item.quantidade} ${item.unidade}.',
      );

      return false;
    }

    final mov = Movimentacao(
      itemId: itemId,
      tipo: tipo,
      quantidade: quantidade,
      responsavel: responsavel.trim(),
      observacao: observacao?.trim().isEmpty ?? true
          ? null
          : observacao!.trim(),
    );

    return run(() async {
      final registrada = await _movimentacaoRepository.registrar(mov);
      ultimaRegistrada = Movimentacao(
        id: registrada.id,
        itemId: registrada.itemId,
        tipo: registrada.tipo,
        quantidade: registrada.quantidade,
        responsavel: registrada.responsavel,
        observacao: registrada.observacao,
        criadoEm: registrada.criadoEm,
        itemNome: item.nome,
      );
    });
  }

  Item? _itemPorId(int id) {
    for (final i in _itens) {
      if (i.id == id) {
        return i;
      }
    }

    return null;
  }
}
