import 'package:cpc_matriz/core/enums.dart';

class Movimentacao {
  const Movimentacao({
    this.id,
    required this.itemId,
    required this.tipo,
    required this.quantidade,
    required this.responsavel,
    this.observacao,
    this.criadoEm,
    this.itemNome,
  });

  final int? id;
  final int itemId;
  final TipoMovimentacao tipo;
  final int quantidade;
  final String responsavel;
  final String? observacao;
  final DateTime? criadoEm;
  final String? itemNome;

  factory Movimentacao.fromMap(Map<String, dynamic> map) {
    return Movimentacao(
      id: map['id'] as int?,
      itemId: map['item_id'] as int,
      tipo: TipoMovimentacao.fromValor(map['tipo'] as String),
      quantidade: map['quantidade'] as int,
      responsavel: map['responsavel'] as String,
      observacao: map['observacao'] as String?,
      criadoEm: map['criado_em'] as DateTime?,
      itemNome: map['item_nome'] as String?,
    );
  }

  Map<String, dynamic> toParams() => {
    'item_id': itemId,
    'tipo': tipo.valor,
    'quantidade': quantidade,
    'responsavel': responsavel,
    'observacao': observacao,
  };
}
