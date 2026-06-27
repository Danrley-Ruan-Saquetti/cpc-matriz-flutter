import 'package:cpc_matriz/core/app_routes.dart';
import 'package:cpc_matriz/core/enums.dart';
import 'package:cpc_matriz/core/theme/app_theme.dart';
import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/persistence_providers.dart';
import 'package:cpc_matriz/data/services/comprovante_service.dart';
import 'package:cpc_matriz/views/comprovante/comprovante_view.dart';
import 'package:cpc_matriz/views/estoque/item_form_view.dart';
import 'package:cpc_matriz/views/home_layout.dart';
import 'package:cpc_matriz/views/movimentacao/movimentacao_form_view.dart';
import 'package:cpc_matriz/views/ticket/ticket_form_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ComprovanteService>(create: (_) => const ComprovanteService()),
        ...buildPersistenceProviders(),
      ],
      child: MaterialApp(
        title: 'CPC - Estoque e Tickets',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.home,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _build((_) => const HomeLayout(), settings);

      case AppRoutes.itemForm:
        final item = settings.arguments as Item?;
        return _build((_) => ItemFormView(item: item), settings);

      case AppRoutes.movimentacaoForm:
        final args =
            settings.arguments as MovimentacaoFormArgs? ??
            const MovimentacaoFormArgs();
        return _build((_) => MovimentacaoFormView(args: args), settings);

      case AppRoutes.ticketForm:
        return _build((_) => const TicketFormView(), settings);

      case AppRoutes.comprovante:
        final args = settings.arguments as ComprovanteArgs;
        return _build((_) => ComprovanteView(args: args), settings);

      default:
        return _build(
          (_) =>
              const Scaffold(body: Center(child: Text('Rota nao encontrada'))),
          settings,
        );
    }
  }

  MaterialPageRoute<dynamic> _build(
    WidgetBuilder builder,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(builder: builder, settings: settings);
  }
}

class MovimentacaoFormArgs {
  const MovimentacaoFormArgs({
    this.itemId,
    this.tipo = TipoMovimentacao.entrada,
  });

  final int? itemId;
  final TipoMovimentacao tipo;
}

class ComprovanteArgs {
  const ComprovanteArgs({required this.titulo, required this.conteudo});

  final String titulo;
  final String conteudo;
}
