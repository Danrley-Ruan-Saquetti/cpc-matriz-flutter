import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/core/utils/formatters.dart';
import 'package:cpc_matriz/data/models/movimentacao.dart';
import 'package:cpc_matriz/data/models/ticket.dart';

class ComprovanteService {
  const ComprovanteService();

  static const String _linha = '----------------------------------------';

  String fromMovimentacao(Movimentacao mov) {
    final tipo = mov.tipo == TipoMovimentacao.entrada ? 'ENTRADA' : 'SAIDA';
    final data = mov.criadoEm != null
        ? Formatters.dateTime(mov.criadoEm!)
        : '-';

    return [
      _linha,
      '   COMPROVANTE DE MOVIMENTACAO',
      ' Evento da Nossa Sra. das Graças',
      _linha,
      'Comprovante n.: ${mov.id ?? '-'}',
      'Data/hora:      $data',
      'Tipo:           $tipo',
      '',
      'Item:           ${mov.itemNome ?? 'Item ${mov.itemId}'}',
      'Quantidade:     ${mov.quantidade}',
      'Responsavel:    ${mov.responsavel}',
      if (mov.observacao != null && mov.observacao!.trim().isNotEmpty)
        'Observacao:     ${mov.observacao}',
      _linha,
      '  Documento sem valor fiscal',
      _linha,
    ].join('\n');
  }

  String fromTicket(Ticket ticket) {
    final data = ticket.criadoEm != null
        ? Formatters.dateTime(ticket.criadoEm!)
        : '-';

    return [
      _linha,
      '         COMPROVANTE DE TICKET',
      '    Evento da Nossa Sra. das Graças',
      _linha,
      'Codigo:         ${ticket.codigo}',
      'Evento:         ${ticket.evento}',
      'Participante:   ${ticket.participante}',
      'Valor:          ${Formatters.currency(ticket.valor)}',
      'Status:         ${ticket.status.rotulo}',
      'Emitido em:     $data',
      if (ticket.utilizadoEm != null)
        'Utilizado em:   ${Formatters.dateTime(ticket.utilizadoEm!)}',
      _linha,
      '  Apresente este comprovante na entrada',
      _linha,
    ].join('\n');
  }
}
