import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/movimentacao.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/sqlite/sqlite_row_mapper.dart';
import 'package:cpc_matriz/data/services/sqlite_database_service.dart';

class SqliteMovimentacaoRepository implements MovimentacaoRepository {
  SqliteMovimentacaoRepository(this._service);

  final SqliteDatabaseService _service;

  static const List<String> _colunasData = ['criado_em'];

  static const String _selectComItem = '''
    SELECT m.*, i.nome AS item_nome
      FROM movimentacoes m
      JOIN itens i ON i.id = m.item_id
  ''';

  Movimentacao _mapToMovimentacao(Map<String, dynamic> row) =>
      Movimentacao.fromMap(hydrateRow(row, _colunasData));

  @override
  Future<List<Movimentacao>> listar() async {
    final db = await _service.database;
    final rows = await db.rawQuery('$_selectComItem ORDER BY m.criado_em DESC');

    return rows.map(_mapToMovimentacao).toList();
  }

  @override
  Future<List<Movimentacao>> listarPorItem(int itemId) async {
    final db = await _service.database;
    final rows = await db.rawQuery(
      '$_selectComItem WHERE m.item_id = ? ORDER BY m.criado_em DESC',
      [itemId],
    );

    return rows.map(_mapToMovimentacao).toList();
  }

  @override
  Future<Movimentacao> registrar(Movimentacao mov) async {
    final db = await _service.database;

    final delta = mov.tipo == TipoMovimentacao.entrada
        ? mov.quantidade
        : -mov.quantidade;

    return db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE itens SET quantidade = quantidade + ? WHERE id = ?',
        [delta, mov.itemId],
      );

      final id = await txn.insert('movimentacoes', mov.toParams());

      final rows = await txn.rawQuery('$_selectComItem WHERE m.id = ?', [id]);

      return _mapToMovimentacao(rows.first);
    });
  }
}
