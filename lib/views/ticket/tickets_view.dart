import 'package:cpc_matriz/app.dart';
import 'package:cpc_matriz/core/app_routes.dart';
import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/core/utils/formatters.dart';
import 'package:cpc_matriz/core/widgets/app_loading.dart';
import 'package:cpc_matriz/core/widgets/feedback.dart';
import 'package:cpc_matriz/core/widgets/state_views.dart';
import 'package:cpc_matriz/data/models/ticket.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/data/services/comprovante_service.dart';
import 'package:cpc_matriz/viewmodels/tickets_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TicketsView extends StatelessWidget {
  const TicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          TicketsViewModel(ctx.read<TicketRepository>())..carregar(),
      child: const _TicketsBody(),
    );
  }
}

class _TicketsBody extends StatelessWidget {
  const _TicketsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: vm.isLoading ? null : vm.carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_tickets',
        onPressed: () async {
          final gerou = await Navigator.pushNamed(
            context,
            AppRoutes.ticketForm,
          );

          if (gerou == true) {
            vm.carregar();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo ticket'),
      ),
      body: Column(
        children: [
          _Resumo(vm: vm),
          _Filtros(vm: vm),
          Expanded(child: _Lista(vm: vm)),
        ],
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.vm});

  final TicketsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _resumoItem(context, 'Validos', '${vm.totalValidos}'),
              _resumoItem(
                context,
                'Arrecadado',
                Formatters.currency(vm.totalArrecadado),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resumoItem(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.vm});

  final TicketsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar por evento, participante ou codigo',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: vm.busca.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => vm.buscar(''),
                    )
                  : null,
            ),
            onChanged: vm.buscar,
          ),

          const SizedBox(height: 8),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: vm.statusFiltro == null,
                  onSelected: (_) => vm.filtrarPorStatus(null),
                ),

                for (final status in StatusTicket.values) ...[
                  const SizedBox(width: 8),

                  ChoiceChip(
                    label: Text(status.rotulo),
                    selected: vm.statusFiltro == status,
                    onSelected: (_) => vm.filtrarPorStatus(status),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.vm});

  final TicketsViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const AppLoading(message: 'Carregando tickets...');
    }

    if (vm.hasError) {
      return ErrorState(
        message: vm.errorMessage ?? 'Erro ao carregar tickets.',
        onRetry: vm.carregar,
      );
    }

    if (vm.vazio) {
      return const EmptyState(
        message:
            'Nenhum ticket encontrado.\nGere um novo ticket no botao abaixo.',
        icon: Icons.confirmation_number_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: vm.carregar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: vm.tickets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) =>
            _TicketCard(ticket: vm.tickets[index], vm: vm),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.vm});

  final Ticket ticket;
  final TicketsViewModel vm;

  Color _colorStatus(StatusTicket status) {
    return switch (status) {
      StatusTicket.valido => Colors.teal,
      StatusTicket.utilizado => Colors.blueGrey,
      StatusTicket.cancelado => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorStatus(ticket.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.evento,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    ticket.status.rotulo,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: color,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text('Participante: ${ticket.participante}'),
            Text('Codigo: ${ticket.codigo}'),
            Text('Valor: ${Formatters.currency(ticket.valor)}'),

            if (ticket.criadoEm != null)
              Text(
                'Emitido: ${Formatters.dateTime(ticket.criadoEm!)}',
                style: theme.textTheme.bodySmall,
              ),

            const Divider(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _verComprovante(context),
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text('Comprovante'),
                ),
                PopupMenuButton<String>(
                  onSelected: (op) => _acao(context, op),
                  itemBuilder: (_) => [
                    if (ticket.status == StatusTicket.valido) ...[
                      _menu('utilizar', Icons.check_circle, 'Marcar utilizado'),
                      _menu('cancelar', Icons.cancel, 'Cancelar'),
                    ],

                    if (ticket.status != StatusTicket.valido)
                      _menu('reativar', Icons.restart_alt, 'Reativar'),
                    _menu('remover', Icons.delete, 'Remover'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menu(String value, IconData icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(text)],
      ),
    );
  }

  Future<void> _verComprovante(BuildContext context) async {
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

  Future<void> _acao(BuildContext context, String op) async {
    switch (op) {
      case 'utilizar':
        await _alterar(context, StatusTicket.utilizado, 'Ticket utilizado.');
      case 'cancelar':
        await _alterar(context, StatusTicket.cancelado, 'Ticket cancelado.');
      case 'reativar':
        await _alterar(context, StatusTicket.valido, 'Ticket reativado.');
      case 'remover':
        await _remover(context);
    }
  }

  Future<void> _alterar(
    BuildContext context,
    StatusTicket status,
    String msg,
  ) async {
    final ok = await vm.alterarStatus(ticket, status);

    if (!context.mounted) {
      return;
    }

    if (ok) {
      AppFeedback.sucesso(context, msg);
    } else {
      AppFeedback.erro(context, vm.errorMessage ?? 'Erro ao atualizar.');
    }
  }

  Future<void> _remover(BuildContext context) async {
    final confirmar = await AppFeedback.confirmar(
      context,
      title: 'Remover ticket',
      message: 'Deseja remover o ticket ${ticket.codigo}?',
      confirmar: 'Remover',
      perigoso: true,
    );

    if (!confirmar || !context.mounted) {
      return;
    }

    final ok = await vm.remover(ticket);

    if (!context.mounted) {
      return;
    }

    if (ok) {
      AppFeedback.sucesso(context, 'Ticket removido.');
    } else {
      AppFeedback.erro(context, vm.errorMessage ?? 'Erro ao remover.');
    }
  }
}
