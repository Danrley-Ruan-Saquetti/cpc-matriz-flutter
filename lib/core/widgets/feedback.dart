import 'package:flutter/material.dart';

class AppFeedback {
  const AppFeedback._();

  static void sucesso(BuildContext context, String message) =>
      _snack(context, message, Colors.green.shade700, Icons.check_circle);

  static void erro(BuildContext context, String message) => _snack(
    context,
    message,
    Theme.of(context).colorScheme.error,
    Icons.error_outline,
  );

  static void info(BuildContext context, String message) => _snack(
    context,
    message,
    Theme.of(context).colorScheme.primary,
    Icons.info_outline,
  );

  static void _snack(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, color: Colors.white),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static Future<bool> confirmar(
    BuildContext context, {
    required String title,
    required String message,
    String confirmar = 'Confirmar',
    String cancelar = 'Cancelar',
    bool perigoso = false,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelar),
          ),
          FilledButton(
            style: perigoso
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmar),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }
}
