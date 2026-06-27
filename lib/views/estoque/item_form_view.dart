import 'package:cpc_matriz/core/utils/validators.dart';
import 'package:cpc_matriz/core/widgets/feedback.dart';
import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/repositories/item_repository.dart';
import 'package:cpc_matriz/viewmodels/item_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ItemFormView extends StatelessWidget {
  const ItemFormView({super.key, this.item});

  final Item? item;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          ItemFormViewModel(ctx.read<ItemRepository>(), item: item),
      child: const _ItemFormBody(),
    );
  }
}

class _ItemFormBody extends StatefulWidget {
  const _ItemFormBody();

  @override
  State<_ItemFormBody> createState() => _ItemFormBodyState();
}

class _ItemFormBodyState extends State<_ItemFormBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nome;
  late final TextEditingController _categoria;
  late final TextEditingController _unidade;
  late final TextEditingController _quantidade;
  late final TextEditingController _quantidadeMinima;
  late final TextEditingController _descricao;

  @override
  void initState() {
    super.initState();

    final item = context.read<ItemFormViewModel>().itemAtual;

    _nome = TextEditingController(text: item?.nome ?? '');
    _categoria = TextEditingController(text: item?.categoria ?? '');
    _unidade = TextEditingController(text: item?.unidade ?? 'un');
    _quantidade = TextEditingController(text: '${item?.quantidade ?? 0}');
    _quantidadeMinima = TextEditingController(
      text: '${item?.quantidadeMinima ?? 0}',
    );
    _descricao = TextEditingController(text: item?.descricao ?? '');
  }

  @override
  void dispose() {
    _nome.dispose();
    _categoria.dispose();
    _unidade.dispose();
    _quantidade.dispose();
    _quantidadeMinima.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<ItemFormViewModel>();

    final ok = await vm.salvar(
      nome: _nome.text,
      categoria: _categoria.text,
      unidade: _unidade.text,
      quantidade: int.parse(_quantidade.text.trim()),
      quantidadeMinima: int.parse(_quantidadeMinima.text.trim()),
      descricao: _descricao.text,
    );

    if (!mounted) {
      return;
    }

    if (ok) {
      AppFeedback.sucesso(
        context,
        vm.editando ? 'Item atualizado!' : 'Item cadastrado!',
      );

      Navigator.pop(context, true);
    } else {
      AppFeedback.erro(context, vm.errorMessage ?? 'Erro ao salvar item.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemFormViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(vm.editando ? 'Editar item' : 'Novo item')),
      body: AbsorbPointer(
        absorbing: vm.isLoading,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) => Validators.required(v, field: 'Nome'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _categoria,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Categoria *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (v) => Validators.required(v, field: 'Categoria'),
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantidade,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Quantidade *',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) =>
                          Validators.integer(v, field: 'Quantidade'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextFormField(
                      controller: _unidade,
                      decoration: const InputDecoration(
                        labelText: 'Unidade *',
                        hintText: 'un, kg, pct',
                      ),
                      validator: (v) =>
                          Validators.required(v, field: 'Unidade'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantidadeMinima,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Quantidade minima *',
                  helperText: 'Alerta de estoque baixo quando atingida',
                  prefixIcon: Icon(Icons.low_priority),
                ),
                validator: (v) =>
                    Validators.integer(v, field: 'Quantidade minima'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descricao,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descricao (opcional)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: vm.isLoading ? null : _salvar,
                icon: vm.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(vm.isLoading ? 'Salvando...' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
