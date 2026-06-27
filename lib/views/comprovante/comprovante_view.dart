import 'package:cpc_matriz/app.dart';
import 'package:cpc_matriz/core/widgets/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComprovanteView extends StatelessWidget {
  const ComprovanteView({super.key, required this.args});

  final ComprovanteArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(args.titulo),
        actions: [
          IconButton(
            tooltip: 'Copiar',
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: args.conteudo));

              if (context.mounted) {
                AppFeedback.sucesso(context, 'Comprovante copiado.');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                args.conteudo,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text('Concluir'),
          ),
        ],
      ),
    );
  }
}
