Map<String, dynamic> hydrateRow(
  Map<String, dynamic> row,
  List<String> dateColumns,
) {
  final map = Map<String, dynamic>.of(row);

  for (final coluna in dateColumns) {
    final valor = map[coluna];

    if (valor is String) {
      map[coluna] = DateTime.tryParse(valor);
    }
  }

  return map;
}
