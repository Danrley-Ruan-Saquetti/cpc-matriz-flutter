import 'package:cpc_matriz/app.dart';
import 'package:cpc_matriz/core/app_routes.dart';
import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/core/utils/formatters.dart';
import 'package:cpc_matriz/core/widgets/app_loading.dart';
import 'package:cpc_matriz/core/widgets/state_views.dart';
import 'package:cpc_matriz/data/models/movimentacao.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/data/services/comprovante_service.dart';
import 'package:cpc_matriz/viewmodels/historico_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoricoView extends StatelessWidget {
  const HistoricoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          HistoricoViewModel(ctx.read<MovimentacaoRepository>())..carregar(),
      child: const _HistoricoBody(),
    );
  }
}

class _HistoricoBody extends StatelessWidget {
  const _HistoricoBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoricoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historico'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: vm.isLoading ? null : vm.carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _Filtros(vm: vm),
          Expanded(child: _Lista(vm: vm)),
        ],
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.vm});

  final HistoricoViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar por item ou responsavel',
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

          Row(
            children: [
              ChoiceChip(
                label: Text('Todas (${vm.totalEntradas + vm.totalSaidas})'),
                selected: vm.tipoFiltro == null,
                onSelected: (_) => vm.filtrarPorTipo(null),
              ),

              const SizedBox(width: 8),

              ChoiceChip(
                label: Text('Entradas (${vm.totalEntradas})'),
                selected: vm.tipoFiltro == TipoMovimentacao.entrada,
                onSelected: (_) => vm.filtrarPorTipo(TipoMovimentacao.entrada),
              ),

              const SizedBox(width: 8),

              ChoiceChip(
                label: Text('Saidas (${vm.totalSaidas})'),
                selected: vm.tipoFiltro == TipoMovimentacao.saida,
                onSelected: (_) => vm.filtrarPorTipo(TipoMovimentacao.saida),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.vm});

  final HistoricoViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const AppLoading(message: 'Carregando historico...');
    }

    if (vm.hasError) {
      return ErrorState(
        message: vm.errorMessage ?? 'Erro ao carregar historico.',
        onRetry: vm.carregar,
      );
    }

    if (vm.vazio) {
      return const EmptyState(
        message: 'Nenhuma movimentacao encontrada.',
        icon: Icons.history,
      );
    }

    return RefreshIndicator(
      onRefresh: vm.carregar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: vm.movimentacoes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) =>
            _MovimentacaoCard(mov: vm.movimentacoes[index]),
      ),
    );
  }
}

class _MovimentacaoCard extends StatelessWidget {
  const _MovimentacaoCard({required this.mov});

  final Movimentacao mov;

  @override
  Widget build(BuildContext context) {
    final entrada = mov.tipo == TipoMovimentacao.entrada;
    final color = entrada ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            entrada ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(
          mov.itemNome ?? 'Item ${mov.itemId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text('${mov.tipo.rotulo} de ${mov.quantidade} un'),
            Text('Responsavel: ${mov.responsavel}'),

            if (mov.criadoEm != null)
              Text(
                Formatters.dateTime(mov.criadoEm!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Comprovante',
          icon: const Icon(Icons.receipt_long),
          onPressed: () => _verComprovante(context),
        ),
        isThreeLine: true,
      ),
    );
  }

  Future<void> _verComprovante(BuildContext context) async {
    final texto = context.read<ComprovanteService>().fromMovimentacao(mov);

    await Navigator.pushNamed(
      context,
      AppRoutes.comprovante,
      arguments: ComprovanteArgs(titulo: 'Comprovante', conteudo: texto),
    );
  }
}
