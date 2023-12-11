import 'package:flutter/material.dart';
import 'package:projeto_01_teste/model/pedidos/pedidos_modal.dart';
import 'package:projeto_01_teste/pages/pedidos/pedidos_api.dart';
import 'package:projeto_01_teste/pages/pedidos/pedidos_pagamentos.dart';
import 'package:projeto_01_teste/pages/pedidos/pedidos_status.dart';

import '../../model/pedidos/pedidos_query_modal.dart';
import '../../utils/delitarCaracter.dart';

class PedidosIndPage extends StatefulWidget {
  final int pedidoId;
  final String pedidoStatus;
  final Function() atualizarPedidos;

  PedidosIndPage(
      {Key? key,
      required this.pedidoId,
      required this.atualizarPedidos,
      required this.pedidoStatus})
      : super(key: key);

  @override
  _PedidosIndPageState createState() => _PedidosIndPageState();
}

class _PedidosIndPageState extends State<PedidosIndPage> {
  late Future<List<Pedidos>> _pedidoDetails;
  final PedidosApi apiService = PedidosApi();

  @override
  void initState() {
    super.initState();
    _pedidoDetails = getPedidos(widget.pedidoId);
  }

  Future<List<Pedidos>> getPedidos(int pedidoId) async {
    // Chame a função getPedidosQuery para obter a lista de ProdutoQuery
    List<ProdutoQuery> produtosQuery =
        await apiService.getPedidosQuery(pedidoId);

    // Agora, você pode criar uma lista de Pedidos com base nos dados de ProdutoQuery
    List<Pedidos> pedidosList = produtosQuery.map((produto) {
      // Use os dados de ProdutoQuery e adicione a variável desejada
      return Pedidos(
        pedId: pedidoId, // Preencha com o ID do pedido
        pedStatus: '', // Preencha com o status desejado
        pedData: '', // Preencha com a data desejada
        usuId: 0, // Preencha com o ID do usuário desejado
        dadosExtras: {
          'pro_id': produto.proId,
          'pep_id': produto.pepId,
          'pro_descricao': produto.proDescricao,
          'pro_preco': produto.proPreco,
          'pep_frete': produto.pepFrete,
          'pro_foto': produto.proFoto,
        },
        produtos: [produto], // Adicione o ProdutoQuery à lista de produtos
      );
    }).toList();

    return pedidosList;
  }

  void _atualizarPagina() async {
    final updatedPedidos = await getPedidos(widget.pedidoId);
    // Calcule a soma dos preços dentro da lista de pedidos atualizados

    setState(() {
      _pedidoDetails = Future.value(updatedPedidos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pedido'),
      ),
      body: FutureBuilder<List<Pedidos>>(
        future: _pedidoDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('Nenhum detalhe encontrado');
          } else {
            // Exiba os detalhes do pedido com base em snapshot.data
            List<Pedidos> detalhes = snapshot.data!;
            double somaTotal = 00.00;

            for (var pedido in detalhes) {
              if (pedido.dadosExtras != null &&
                  pedido.dadosExtras!.containsKey('pro_preco')) {
                somaTotal +=
                    double.parse(pedido.dadosExtras!['pro_preco'].toString());
              }
            }
            String lucroString = somaTotal.toStringAsFixed(2);

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: detalhes.length,
                    itemBuilder: (context, index) {
                      Pedidos pedido = detalhes[index];
                      Map<String, dynamic>? dadosExtras =
                          pedido.dadosExtras; // Acesse os dados extras

                      return Container(
                        margin:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white, // Cor de fundo
                          borderRadius:
                              BorderRadius.circular(10.0), // Borda arredondada
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3), // Sombra
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    limitarTexto(
                                        '${dadosExtras?['pro_descricao'] ?? ''}',
                                        15), // Limita a 20 caracteres
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight
                                          .bold, // Pode ser FontWeight.bold para negrito, se desejar
                                      color: Colors.black, // Cor do texto
                                      // Outras propriedades de estilo de fonte podem ser adicionadas aqui
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'R\$ ${dadosExtras?['pro_preco']}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            widget.pedidoStatus != "Encerrado"
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final classe = PedidosApi();
                                      final bool? produtoExcluido =
                                          await classe.PedidoProdutoExcluido(
                                        dadosExtras?['pep_id'] ?? 0,
                                        widget.pedidoId,
                                        dadosExtras?['pro_id'] ?? 0,
                                      );
                                      if (produtoExcluido == true) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Produto excluido com sucesso'),
                                              content: const Text(
                                                  'Clique em OK para voltar ao seu pedido.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () async {
                                                    _atualizarPagina();
                                                    Navigator.pop(
                                                        context, true);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        // O pedido não pôde ser encerrado, você pode mostrar uma mensagem de erro aqui
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'O produto já foi excluido'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : Container()
                          ],
                        ),
                      );
                    },
                  ),
                ),
                widget.pedidoStatus != "Encerrado"
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(16.0, 8, 12, 16),
                        color: Colors.white,
                        // Defina a cor de fundo desejada
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total R\$ ${lucroString}',
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PedidosPagamento(
                                      valorTotal: somaTotal,
                                      pedidoId: widget.pedidoId,
                                      atualizarPedidos: widget.atualizarPedidos,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Confirmar pedido',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight
                                      .bold, // Pode ser FontWeight.bold para negrito, se desejar
                                  // Cor do texto
                                  // Outras propriedades de estilo de fonte podem ser adicionadas aqui
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    //CASO O PEDIDO SEJA CONCLUIDO MOSTRE O STATUS
                    : Container(
                        padding: const EdgeInsets.fromLTRB(16.0, 8, 12, 16),
                        color: Colors.white,
                        // Defina a cor de fundo desejada
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Veja o status do seu pedido',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PedidoStatus(
                                      atualizarPedidos: widget.atualizarPedidos,
                                      pedidoId: widget.pedidoId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight
                                      .bold, // Pode ser FontWeight.bold para negrito, se desejar
                                  // Cor do texto
                                  // Outras propriedades de estilo de fonte podem ser adicionadas aqui
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
              ],
            );
          }
        },
      ),
    );
  }
}
