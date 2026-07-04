import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/data/models/movimentacao.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/data/services/postgresql_database_service.dart';
import 'package:postgres/postgres.dart';

class PostgresMovimentacaoRepository implements MovimentacaoRepository {
  PostgresMovimentacaoRepository(this._db);

  final PostgresDatabaseService _db;

  static const String _selectComItem = '''
    SELECT m.*, i.nome AS item_nome
      FROM movimentacoes m
      JOIN itens i ON i.id = m.item_id
  ''';

  @override
  Future<List<Movimentacao>> listar() async {
    final linhas = await _db.query('$_selectComItem ORDER BY m.criado_em DESC');

    return linhas.map(Movimentacao.fromMap).toList();
  }

  @override
  Future<List<Movimentacao>> listarPorItem(int itemId) async {
    final linhas = await _db.query(
      '$_selectComItem WHERE m.item_id = @item_id ORDER BY m.criado_em DESC',
      parameters: {'item_id': itemId},
    );

    return linhas.map(Movimentacao.fromMap).toList();
  }

  @override
  Future<Movimentacao> registrar(Movimentacao mov) async {
    final delta = mov.tipo == TipoMovimentacao.entrada
        ? mov.quantidade
        : -mov.quantidade;

    return _db.runTransaction<Movimentacao>((tx) async {
      await tx.execute(
        Sql.named(
          'UPDATE itens SET quantidade = quantidade + @delta WHERE id = @id',
        ),
        parameters: {'delta': delta, 'id': mov.itemId},
      );

      final inserido = await tx.execute(
        Sql.named('''
          INSERT INTO movimentacoes (item_id, tipo, quantidade, responsavel, observacao)
          VALUES (@item_id, @tipo, @quantidade, @responsavel, @observacao)
          RETURNING *
        '''),
        parameters: mov.toParams(),
      );

      return Movimentacao.fromMap(inserido.first.toColumnMap());
    });
  }
}
