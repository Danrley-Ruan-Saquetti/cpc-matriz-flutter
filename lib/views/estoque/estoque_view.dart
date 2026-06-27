import 'package:cpc_matriz/app.dart';
import 'package:cpc_matriz/core/app_routes.dart';
import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/core/widgets/app_loading.dart';
import 'package:cpc_matriz/core/widgets/feedback.dart';
import 'package:cpc_matriz/core/widgets/state_views.dart';
import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/viewmodels/estoque_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EstoqueView extends StatelessWidget {
  const EstoqueView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => EstoqueViewModel(ctx.read<ItemRepository>())..carregar(),
      child: const _EstoqueBody(),
    );
  }
}

class _EstoqueBody extends StatelessWidget {
  const _EstoqueBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EstoqueViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: vm.isLoading ? null : vm.carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_estoque',
        onPressed: () => _abrirFormulario(context, vm),
        icon: const Icon(Icons.add),
        label: const Text('Novo item'),
      ),
      body: Column(
        children: [
          _Filtros(vm: vm),
          Expanded(child: _Lista(vm: vm)),
        ],
      ),
    );
  }

  Future<void> _abrirFormulario(
    BuildContext context,
    EstoqueViewModel vm, [
    Item? item,
  ]) async {
    final salvou = await Navigator.pushNamed(
      context,
      AppRoutes.itemForm,
      arguments: item,
    );

    if (salvou == true) {
      vm.carregar();
    }
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.vm});

  final EstoqueViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar por nome ou categoria',
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
                FilterChip(
                  label: const Text('Estoque baixo'),
                  selected: vm.apenasEstoqueBaixo,
                  avatar: const Icon(Icons.warning_amber_rounded, size: 18),
                  onSelected: vm.alternarEstoqueBaixo,
                ),

                const SizedBox(width: 8),

                ChoiceChip(
                  label: const Text('Todas'),
                  selected: vm.categoriaSelecionada == null,
                  onSelected: (_) => vm.filtrarPorCategoria(null),
                ),

                for (final categoria in vm.categorias) ...[
                  const SizedBox(width: 8),

                  ChoiceChip(
                    label: Text(categoria),
                    selected: vm.categoriaSelecionada == categoria,
                    onSelected: (_) => vm.filtrarPorCategoria(categoria),
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

  final EstoqueViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const AppLoading(message: 'Carregando itens...');
    }
    if (vm.hasError) {
      return ErrorState(
        message: vm.errorMessage ?? 'Erro ao carregar itens.',
        onRetry: vm.carregar,
      );
    }
    if (vm.vazio) {
      return const EmptyState(
        message:
            'Nenhum item encontrado.\nCadastre um novo item ou ajuste os filtros.',
        icon: Icons.inventory_2_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: vm.carregar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: vm.itens.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = vm.itens[index];
          return _ItemCard(item: item, vm: vm);
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.vm});

  final Item item;
  final EstoqueViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            item.nome.isNotEmpty ? item.nome[0].toUpperCase() : '?',
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(
          item.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text('${item.categoria} - ${item.quantidade} ${item.unidade}'),

            if (item.estoqueBaixo)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Estoque baixo',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (op) => _acao(context, op),
          itemBuilder: (_) => [
            _menu('entrada', Icons.login, 'Registrar entrada'),
            _menu('saida', Icons.logout, 'Registrar saida'),
            _menu('editar', Icons.edit, 'Editar'),
            _menu('remover', Icons.delete, 'Remover'),
          ],
        ),
        onTap: () => _editar(context),
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

  Future<void> _acao(BuildContext context, String op) async {
    switch (op) {
      case 'editar':
        _editar(context);
      case 'entrada':
        _movimentar(context, TipoMovimentacao.entrada);
      case 'saida':
        _movimentar(context, TipoMovimentacao.saida);
      case 'remover':
        _remover(context);
    }
  }

  Future<void> _editar(BuildContext context) async {
    final salvou = await Navigator.pushNamed(
      context,
      AppRoutes.itemForm,
      arguments: item,
    );

    if (salvou == true) {
      vm.carregar();
    }
  }

  Future<void> _movimentar(BuildContext context, TipoMovimentacao tipo) async {
    final registrou = await Navigator.pushNamed(
      context,
      AppRoutes.movimentacaoForm,
      arguments: MovimentacaoFormArgs(itemId: item.id, tipo: tipo),
    );
    if (registrou == true) vm.carregar();
  }

  Future<void> _remover(BuildContext context) async {
    final confirmar = await AppFeedback.confirmar(
      context,
      title: 'Remover item',
      message:
          'Deseja remover "${item.nome}"? '
          'As movimentacoes relacionadas tambem serao apagadas.',
      confirmar: 'Remover',
      perigoso: true,
    );
    if (!confirmar || !context.mounted) return;

    final ok = await vm.remover(item);
    if (!context.mounted) return;
    if (ok) {
      AppFeedback.sucesso(context, 'Item removido com sucesso.');
    } else {
      AppFeedback.erro(context, vm.errorMessage ?? 'Erro ao remover item.');
    }
  }
}
