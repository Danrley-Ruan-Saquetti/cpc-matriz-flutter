import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static final DateFormat _data = DateFormat('dd/MM/yyyy');
  static final DateFormat _dataHora = DateFormat('dd/MM/yyyy HH:mm');
  static final NumberFormat _moeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
  );

  static String date(DateTime value) => _data.format(value);

  static String dateTime(DateTime value) => _dataHora.format(value);

  static String currency(num value) => _moeda.format(value);
}
