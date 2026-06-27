import 'package:cpc_matriz/app.dart';
import 'package:cpc_matriz/core/app_routes.dart';
import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/core/utils/validators.dart';
import 'package:cpc_matriz/core/widgets/app_loading.dart';
import 'package:cpc_matriz/core/widgets/feedback.dart';
import 'package:cpc_matriz/core/widgets/state_views.dart';
import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/data/repositories/movimentacao_repository.dart';
import 'package:cpc_matriz/data/services/comprovante_service.dart';
import 'package:cpc_matriz/viewmodels/movimentacao_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MovimentacaoFormView extends StatelessWidget {
  const MovimentacaoFormView({super.key, required this.args});

  final MovimentacaoFormArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => MovimentacaoFormViewModel(
        ctx.read<ItemRepository>(),
        ctx.read<MovimentacaoRepository>(),
        itemInicialId: args.itemId,
        tipoInicial: args.tipo,
      )..carregarItens(),
      child: const _MovimentacaoFormBody(),
    );
  }
}

class _MovimentacaoFormBody extends StatefulWidget {
  const _MovimentacaoFormBody();

  @override
  State<_MovimentacaoFormBody> createState() => _MovimentacaoFormBodyState();
}

class _MovimentacaoFormBodyState extends State<_MovimentacaoFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _quantidade = TextEditingController(text: '1');
  final _responsavel = TextEditingController();
  final _observacao = TextEditingController();

  int? _itemId;
  late TipoMovimentacao _tipo;
  bool _iniciado = false;

  @override
  void initState() {
    super.initState();

    final vm = context.read<MovimentacaoFormViewModel>();
    _tipo = vm.tipoInicial;
    _itemId = vm.itemInicialId;
  }

  @override
  void dispose() {
    _quantidade.dispose();
    _responsavel.dispose();
    _observacao.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_itemId == null) {
      AppFeedback.erro(context, 'Selecione um item.');
      return;
    }

    final vm = context.read<MovimentacaoFormViewModel>();

    final ok = await vm.registrar(
      itemId: _itemId!,
      tipo: _tipo,
      quantidade: int.parse(_quantidade.text.trim()),
      responsavel: _responsavel.text,
      observacao: _observacao.text,
    );

    if (!mounted) {
      return;
    }

    if (ok) {
      AppFeedback.sucesso(context, 'Movimentacao registrada!');

      await _oferecerComprovante(vm);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      AppFeedback.erro(
        context,
        vm.errorMessage ?? 'Erro ao registrar movimentacao.',
      );
    }
  }

  Future<void> _oferecerComprovante(MovimentacaoFormViewModel vm) async {
    final mov = vm.ultimaRegistrada;

    if (mov == null) {
      return;
    }

    final ver = await AppFeedback.confirmar(
      context,
      title: 'Comprovante',
      message: 'Deseja visualizar o comprovante desta movimentacao?',
      confirmar: 'Ver comprovante',
      cancelar: 'Agora nao',
    );

    if (!ver || !mounted) {
      return;
    }

    final texto = context.read<ComprovanteService>().fromMovimentacao(mov);

    await Navigator.pushNamed(
      context,
      AppRoutes.comprovante,
      arguments: ComprovanteArgs(titulo: 'Comprovante', conteudo: texto),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MovimentacaoFormViewModel>();

    if (!_iniciado && vm.itens.isNotEmpty) {
      _iniciado = true;

      if (_itemId == null || !vm.itens.any((i) => i.id == _itemId)) {
        _itemId = vm.itens.first.id;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar movimentacao')),
      body: _corpo(vm),
    );
  }

  Widget _corpo(MovimentacaoFormViewModel vm) {
    if (vm.isLoading && vm.itens.isEmpty) {
      return const AppLoading(message: 'Carregando itens...');
    }

    if (vm.hasError && vm.itens.isEmpty) {
      return ErrorState(
        message: vm.errorMessage ?? 'Erro ao carregar itens.',
        onRetry: vm.carregarItens,
      );
    }

    if (vm.itens.isEmpty) {
      return const EmptyState(
        message:
            'Cadastre um item no estoque antes de registrar movimentacoes.',
        icon: Icons.inventory_2_outlined,
      );
    }

    return AbsorbPointer(
      absorbing: vm.isLoading,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TipoMovimentacao>(
              segments: const [
                ButtonSegment(
                  value: TipoMovimentacao.entrada,
                  label: Text('Entrada'),
                  icon: Icon(Icons.login),
                ),
                ButtonSegment(
                  value: TipoMovimentacao.saida,
                  label: Text('Saida'),
                  icon: Icon(Icons.logout),
                ),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<int>(
              initialValue: _itemId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Item *',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              items: [
                for (final Item i in vm.itens)
                  DropdownMenuItem(
                    value: i.id,
                    child: Text(
                      '${i.nome} (${i.quantidade} ${i.unidade})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _itemId = v),
              validator: (v) => v == null ? 'Selecione um item' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _quantidade,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Quantidade *',
                prefixIcon: Icon(Icons.numbers),
              ),
              validator: (v) =>
                  Validators.integer(v, min: 1, field: 'Quantidade'),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _responsavel,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Responsavel *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => Validators.required(v, field: 'Responsavel'),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _observacao,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Observacao (opcional)',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: vm.isLoading ? null : _registrar,
              icon: vm.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(vm.isLoading ? 'Registrando...' : 'Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
