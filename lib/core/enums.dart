enum TipoMovimentacao {
  entrada('entrada', 'Entrada'),
  saida('saida', 'Saida');

  const TipoMovimentacao(this.valor, this.rotulo);

  final String valor;

  final String rotulo;

  static TipoMovimentacao fromValor(String valor) {
    return values.firstWhere((e) => e.valor == valor, orElse: () => entrada);
  }
}

enum StatusTicket {
  valido('valido', 'Valido'),
  utilizado('utilizado', 'Utilizado'),
  cancelado('cancelado', 'Cancelado');

  const StatusTicket(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static StatusTicket fromValor(String valor) {
    return values.firstWhere((e) => e.valor == valor, orElse: () => valido);
  }
}
