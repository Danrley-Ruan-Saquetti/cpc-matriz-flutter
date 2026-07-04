import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/data/services/postgresql_database_service.dart';

class PostgresItemRepository implements ItemRepository {
  PostgresItemRepository(this._db);

  final PostgresDatabaseService _db;

  @override
  Future<List<Item>> listar() async {
    final linhas = await _db.query('SELECT * FROM itens ORDER BY nome ASC');

    return linhas.map(Item.fromMap).toList();
  }

  @override
  Future<Item?> buscarPorId(int id) async {
    final linhas = await _db.query(
      'SELECT * FROM itens WHERE id = @id',
      parameters: {'id': id},
    );

    if (linhas.isEmpty) {
      return null;
    }

    return Item.fromMap(linhas.first);
  }

  @override
  Future<Item> criar(Item item) async {
    final linha = await _db.execute('''
      INSERT INTO itens (nome, categoria, unidade, quantidade, quantidade_minima, descricao)
      VALUES (@nome, @categoria, @unidade, @quantidade, @quantidade_minima, @descricao)
      RETURNING *
      ''', parameters: item.toParams());

    return Item.fromMap(linha!);
  }

  @override
  Future<Item> atualizar(Item item) async {
    final linha = await _db.execute(
      '''
      UPDATE itens
         SET nome = @nome,
             categoria = @categoria,
             unidade = @unidade,
             quantidade = @quantidade,
             quantidade_minima = @quantidade_minima,
             descricao = @descricao
       WHERE id = @id
      RETURNING *
      ''',
      parameters: {...item.toParams(), 'id': item.id},
    );

    return Item.fromMap(linha!);
  }

  @override
  Future<void> remover(int id) async {
    await _db.execute(
      'DELETE FROM itens WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
