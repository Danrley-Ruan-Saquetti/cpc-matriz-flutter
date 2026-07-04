import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/data/repositories/sqlite/sqlite_row_mapper.dart';
import 'package:cpc_matriz/data/services/sqlite_database_service.dart';

class SqliteItemRepository implements ItemRepository {
  SqliteItemRepository(this._service);

  final SqliteDatabaseService _service;

  static const List<String> _colunasData = ['criado_em'];

  Item _mapToItem(Map<String, dynamic> row) =>
      Item.fromMap(hydrateRow(row, _colunasData));

  @override
  Future<List<Item>> listar() async {
    final db = await _service.database;
    final rows = await db.query('itens', orderBy: 'nome ASC');

    return rows.map(_mapToItem).toList();
  }

  @override
  Future<Item?> findById(int id) async {
    final db = await _service.database;

    final rows = await db.query(
      'itens',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapToItem(rows.first);
  }

  @override
  Future<Item> criar(Item item) async {
    final db = await _service.database;
    final id = await db.insert('itens', item.toParams());

    return (await findById(id))!;
  }

  @override
  Future<Item> atualizar(Item item) async {
    final db = await _service.database;

    await db.update(
      'itens',
      item.toParams(),
      where: 'id = ?',
      whereArgs: [item.id],
    );

    return (await findById(item.id!))!;
  }

  @override
  Future<void> remover(int id) async {
    final db = await _service.database;
    await db.delete('itens', where: 'id = ?', whereArgs: [id]);
  }
}
