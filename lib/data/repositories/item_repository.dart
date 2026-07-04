import 'package:cpc_matriz/data/models/item.dart';

abstract interface class ItemRepository {
  Future<List<Item>> listar();
  Future<Item?> findById(int id);
  Future<Item> criar(Item item);
  Future<Item> atualizar(Item item);
  Future<void> remover(int id);
}
