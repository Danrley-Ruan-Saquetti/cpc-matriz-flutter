import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/viewmodels/base_viewmodel.dart';

class ItemFormViewModel extends BaseViewModel {
  ItemFormViewModel(this._repository, {Item? item}) : _original = item;

  final ItemRepository _repository;
  final Item? _original;

  bool get editando => _original != null;
  Item? get itemAtual => _original;

  Future<bool> salvar({
    required String nome,
    required String categoria,
    required String unidade,
    required int quantidade,
    required int quantidadeMinima,
    String? descricao,
  }) async {
    final item = Item(
      id: _original?.id,
      nome: nome.trim(),
      categoria: categoria.trim(),
      unidade: unidade.trim(),
      quantidade: quantidade,
      quantidadeMinima: quantidadeMinima,
      descricao: descricao?.trim().isEmpty ?? true ? null : descricao!.trim(),
    );

    return run(() async {
      if (editando) {
        await _repository.atualizar(item);
      } else {
        await _repository.criar(item);
      }
    });
  }
}
