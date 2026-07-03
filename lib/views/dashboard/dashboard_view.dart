import 'package:cpc_matriz/app.dart';
import 'package:cpc_matriz/core/app_routes.dart';
import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/core/utils/formatters.dart';
import 'package:cpc_matriz/core/widgets/app_loading.dart';
import 'package:cpc_matriz/core/widgets/stat_card.dart';
import 'package:cpc_matriz/core/widgets/state_views.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/data/repositories/ticket_repository.dart';
import 'package:cpc_matriz/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => DashboardViewModel(
        ctx.read<ItemRepository>(),
        ctx.read<MovimentacaoRepository>(),
        ctx.read<TicketRepository>(),
      )..carregar(),
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CPC - Painel'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: vm.isLoading ? null : vm.carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (vm.isLoading) {
            return const AppLoading(message: 'Carregando indicadores...');
          }

          if (vm.hasError) {
            return ErrorState(
              message: vm.errorMessage ?? 'Erro ao carregar dados.',
              onRetry: vm.carregar,
            );
          }

          return RefreshIndicator(
            onRefresh: vm.carregar,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Resumo geral',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    StatCard(
                      title: 'Itens cadastrados',
                      value: '${vm.totalItens}',
                      icon: Icons.inventory_2,
                      color: Colors.indigo,
                    ),
                    StatCard(
                      title: 'Estoque baixo',
                      value: '${vm.totalEstoqueBaixo}',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.orange.shade800,
                    ),
                    StatCard(
                      title: 'Tickets validos',
                      value: '${vm.ticketsValidos}',
                      icon: Icons.confirmation_number,
                      color: Colors.teal,
                    ),
                    StatCard(
                      title: 'Arrecadado',
                      value: Formatters.currency(vm.totalArrecadado),
                      icon: Icons.payments,
                      color: Colors.green.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Ações rapidas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _AcoesRapidas(onAcaoConcluida: vm.carregar),
                const SizedBox(height: 24),
                _AlertasEstoque(vm: vm),
                const SizedBox(height: 24),
                Text(
                  'Movimentacoes recentes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _MovimentacoesRecentes(vm: vm),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AcoesRapidas extends StatelessWidget {
  const _AcoesRapidas({required this.onAcaoConcluida});

  final VoidCallback onAcaoConcluida;

  @override
  Widget build(BuildContext context) {
    Future<void> abrir(String rota, [Object? args]) async {
      await Navigator.pushNamed(context, rota, arguments: args);
      onAcaoConcluida();
    }

    return Row(
      children: [
        Expanded(
          child: _BotaoAcao(
            icon: Icons.login,
            rotulo: 'Entrada',
            onTap: () => abrir(
              AppRoutes.movimentacaoForm,
              const MovimentacaoFormArgs(tipo: TipoMovimentacao.entrada),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BotaoAcao(
            icon: Icons.logout,
            rotulo: 'Saida',
            onTap: () => abrir(
              AppRoutes.movimentacaoForm,
              const MovimentacaoFormArgs(tipo: TipoMovimentacao.saida),
            ),
          ),
        ),
      ],
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  const _BotaoAcao({
    required this.icon,
    required this.rotulo,
    required this.onTap,
  });

  final IconData icon;
  final String rotulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        foregroundColor: theme.colorScheme.primary,
      ),
      icon: Icon(icon),
      label: Text(rotulo),
    );
  }
}

class _AlertasEstoque extends StatelessWidget {
  const _AlertasEstoque({required this.vm});

  final DashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final itens = vm.itensEstoqueBaixo;
    if (itens.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                Text(
                  'Itens com estoque baixo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...itens
                .take(4)
                .map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '- ${i.nome}: ${i.quantidade} ${i.unidade} '
                      '(minimo ${i.quantidadeMinima})',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _MovimentacoesRecentes extends StatelessWidget {
  const _MovimentacoesRecentes({required this.vm});

  final DashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final movs = vm.movimentacoesRecentes;
    if (movs.isEmpty) {
      return const EmptyState(
        message: 'Nenhuma movimentacao registrada ainda.',
        icon: Icons.swap_vert,
      );
    }
    return Card(
      child: Column(
        children: [
          for (final m in movs)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: m.tipo == TipoMovimentacao.entrada
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                child: Icon(
                  m.tipo == TipoMovimentacao.entrada
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: m.tipo == TipoMovimentacao.entrada
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
              title: Text(m.itemNome ?? 'Item ${m.itemId}'),
              subtitle: Text(
                '${m.tipo.rotulo} - ${m.quantidade} un - ${m.responsavel}',
              ),
              trailing: Text(
                m.criadoEm != null ? Formatters.date(m.criadoEm!) : '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
