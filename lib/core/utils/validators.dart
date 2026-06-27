class Validators {
  const Validators._();

  static String? required(String? value, {String field = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field e obrigatorio';
    }

    return null;
  }

  static String? integer(String? value, {int min = 0, String field = 'Valor'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field e obrigatorio';
    }

    final n = int.tryParse(value.trim());

    if (n == null) {
      return 'Informe um numero inteiro valido';
    }

    if (n < min) {
      return '$field deve ser maior ou igual a $min';
    }

    return null;
  }

  static String? currency(String? value, {String field = 'Valor'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field e obrigatorio';
    }

    final n = double.tryParse(value.trim().replaceAll(',', '.'));

    if (n == null) {
      return 'Informe um valor valido';
    }

    if (n < 0) {
      return '$field nao pode ser negativo';
    }

    return null;
  }
}
