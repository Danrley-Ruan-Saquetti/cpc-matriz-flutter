import 'package:cpc_matriz/core/enums.dart';

class Ticket {
  const Ticket({
    this.id,
    required this.codigo,
    required this.evento,
    required this.participante,
    required this.valor,
    required this.status,
    this.criadoEm,
    this.utilizadoEm,
  });

  final int? id;
  final String codigo;
  final String evento;
  final String participante;
  final double valor;
  final StatusTicket status;
  final DateTime? criadoEm;
  final DateTime? utilizadoEm;

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'] as int?,
      codigo: map['codigo'] as String,
      evento: map['evento'] as String,
      participante: map['participante'] as String,
      valor: _paraDouble(map['valor']),
      status: StatusTicket.fromValor(map['status'] as String),
      criadoEm: map['criado_em'] as DateTime?,
      utilizadoEm: map['utilizado_em'] as DateTime?,
    );
  }

  Map<String, dynamic> toParams() => {
    'codigo': codigo,
    'evento': evento,
    'participante': participante,
    'valor': valor,
    'status': status.valor,
  };

  static double _paraDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
