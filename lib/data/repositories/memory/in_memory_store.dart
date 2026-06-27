import 'package:cpc_matriz/data/models/item.dart';
import 'package:cpc_matriz/data/models/movimentacao.dart';
import 'package:cpc_matriz/data/models/ticket.dart';

class InMemoryStore {
  InMemoryStore() {
    _seed();
  }

  final List<Item> itens = [];
  final List<Movimentacao> movimentacoes = [];
  final List<Ticket> tickets = [];

  int _itemSeq = 0;
  int _movSeq = 0;
  int _ticketSeq = 0;

  int get proximoItemId => ++_itemSeq;
  int get proximaMovId => ++_movSeq;
  int get proximoTicketId => ++_ticketSeq;

  void _seed() {
    final agora = DateTime.now();

    itens.addAll([
      Item(
        id: proximoItemId,
        nome: 'Agua mineral 500ml',
        categoria: 'Bebidas',
        unidade: 'un',
        quantidade: 48,
        quantidadeMinima: 24,
        descricao: 'Garrafas para eventos',
        criadoEm: agora,
      ),
      Item(
        id: proximoItemId,
        nome: 'Cafe em po 500g',
        categoria: 'Alimentos',
        unidade: 'pct',
        quantidade: 5,
        quantidadeMinima: 6,
        descricao: 'Usado nos cultos da manha',
        criadoEm: agora,
      ),
      Item(
        id: proximoItemId,
        nome: 'Cadeira plastica',
        categoria: 'Mobiliario',
        unidade: 'un',
        quantidade: 120,
        quantidadeMinima: 50,
        descricao: 'Cadeiras brancas empilhaveis',
        criadoEm: agora,
      ),
    ]);
  }
}
