import 'package:cpc_matriz/app.dart';
import 'package:cpc_matriz/core/app_routes.dart';
import 'package:cpc_matriz/core/utils/validators.dart';
import 'package:cpc_matriz/core/widgets/feedback.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/data/services/comprovante_service.dart';
import 'package:cpc_matriz/viewmodels/ticket_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TicketFormView extends StatelessWidget {
  const TicketFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => TicketFormViewModel(ctx.read<TicketRepository>()),
      child: const _TicketFormBody(),
    );
  }
}

class _TicketFormBody extends StatefulWidget {
  const _TicketFormBody();

  @override
  State<_TicketFormBody> createState() => _TicketFormBodyState();
}

class _TicketFormBodyState extends State<_TicketFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _evento = TextEditingController();
  final _participante = TextEditingController();
  final _valor = TextEditingController(text: '0,00');

  @override
  void dispose() {
    _evento.dispose();
    _participante.dispose();
    _valor.dispose();
    super.dispose();
  }

  Future<void> _gerar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<TicketFormViewModel>();

    final ok = await vm.gerar(
      evento: _evento.text,
      participante: _participante.text,
      valor: double.parse(_valor.text.trim().replaceAll(',', '.')),
    );

    if (!mounted) {
      return;
    }

    if (ok) {
      AppFeedback.sucesso(context, 'Ticket ${vm.ultimoGerado!.codigo} gerado!');

      await _oferecerComprovante(vm);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      AppFeedback.erro(context, vm.errorMessage ?? 'Erro ao gerar ticket.');
    }
  }

  Future<void> _oferecerComprovante(TicketFormViewModel vm) async {
    final ticket = vm.ultimoGerado;

    if (ticket == null) {
      return;
    }

    final ver = await AppFeedback.confirmar(
      context,
      title: 'Comprovante',
      message: 'Ticket gerado! Deseja visualizar o comprovante?',
      confirmar: 'Ver comprovante',
      cancelar: 'Agora nao',
    );

    if (!ver || !mounted) {
      return;
    }

    final texto = context.read<ComprovanteService>().fromTicket(ticket);

    await Navigator.pushNamed(
      context,
      AppRoutes.comprovante,
      arguments: ComprovanteArgs(
        titulo: 'Comprovante do ticket',
        conteudo: texto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketFormViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gerar ticket')),
      body: AbsorbPointer(
        absorbing: vm.isLoading,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _evento,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Evento *',
                  prefixIcon: Icon(Icons.event),
                ),
                validator: (v) => Validators.required(v, field: 'Evento'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _participante,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Participante *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => Validators.required(v, field: 'Participante'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _valor,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$) *',
                  helperText: 'Use 0 para tickets gratuitos',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) => Validators.currency(v, field: 'Valor'),
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: vm.isLoading ? null : _gerar,
                icon: vm.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.confirmation_number),
                label: Text(vm.isLoading ? 'Gerando...' : 'Gerar ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
