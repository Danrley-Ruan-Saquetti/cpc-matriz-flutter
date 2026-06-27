import 'package:cpc_matriz/data/models/movimentacao.dart';

abstract interface class MovimentacaoRepository {
  Future<List<Movimentacao>> listar();
  Future<List<Movimentacao>> listarPorItem(int itemId);
  Future<Movimentacao> registrar(Movimentacao mov);
}
