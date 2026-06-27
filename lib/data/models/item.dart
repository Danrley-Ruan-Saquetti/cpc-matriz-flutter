class Item {
  const Item({
    this.id,
    required this.nome,
    required this.categoria,
    required this.unidade,
    required this.quantidade,
    required this.quantidadeMinima,
    this.descricao,
    this.criadoEm,
  });

  final int? id;
  final String nome;
  final String categoria;
  final String unidade;
  final int quantidade;
  final int quantidadeMinima;
  final String? descricao;
  final DateTime? criadoEm;

  bool get estoqueBaixo => quantidade <= quantidadeMinima;

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      categoria: map['categoria'] as String,
      unidade: map['unidade'] as String,
      quantidade: map['quantidade'] as int,
      quantidadeMinima: map['quantidade_minima'] as int,
      descricao: map['descricao'] as String?,
      criadoEm: map['criado_em'] as DateTime?,
    );
  }

  Map<String, dynamic> toParams() => {
    'nome': nome,
    'categoria': categoria,
    'unidade': unidade,
    'quantidade': quantidade,
    'quantidade_minima': quantidadeMinima,
    'descricao': descricao,
  };

  Item copyWith({
    int? id,
    String? nome,
    String? categoria,
    String? unidade,
    int? quantidade,
    int? quantidadeMinima,
    String? descricao,
  }) {
    return Item(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      unidade: unidade ?? this.unidade,
      quantidade: quantidade ?? this.quantidade,
      quantidadeMinima: quantidadeMinima ?? this.quantidadeMinima,
      descricao: descricao ?? this.descricao,
      criadoEm: criadoEm,
    );
  }
}
