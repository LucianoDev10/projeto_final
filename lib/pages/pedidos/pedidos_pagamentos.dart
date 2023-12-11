import 'package:flutter/material.dart';
import 'package:projeto_01_teste/model/entregas/rotas_modal.dart';
import 'package:projeto_01_teste/pages/pedidos/pedidos_api.dart';

class PedidosPagamento extends StatefulWidget {
  final double? valorTotal;
  final int? pedidoId;
  final Function() atualizarPedidos;

  PedidosPagamento({
    Key? key,
    required this.valorTotal,
    required this.pedidoId,
    required this.atualizarPedidos,
  }) : super(key: key);

  @override
  _PedidosPagamentoState createState() => _PedidosPagamentoState();
}

class _PedidosPagamentoState extends State<PedidosPagamento> {
  late Future<Rota?> _rotaDetails;
  String? formaPagamentoSelecionada;
  final List<String> formasPagamento = [
    'PIX',
    'Cartão de Crédito',
    'Cartão de Débito'
  ];

  @override
  void initState() {
    super.initState();
    _rotaDetails = PedidosApi.calcularRota();
    if (formasPagamento.isNotEmpty) {
      formaPagamentoSelecionada = formasPagamento.first;
    }
  }

  String? _validarMin(String? text) {
    if (text!.isEmpty) {
      return "Digite seu Nome Completo";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo de pagamento'),
      ),
      body: FutureBuilder<Rota?>(
        future: _rotaDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (!snapshot.hasData) {
            return const Text('Nenhum detalhe encontrado');
          } else {
            Rota rotas = snapshot.data!;
            String lucroString = widget.valorTotal!.toStringAsFixed(2);

            return Column(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: const Text(
                        "Detalhes sobre o pedido",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
                      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Frete:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'R\$ ${rotas.price}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Valor do pedido:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'R\$ ${lucroString}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Container(
                            height: 1.0, // Altura da linha
                            color: Colors.grey, // Cor da linha
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Valor total:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'R\$ ${(widget.valorTotal ?? 0) + (rotas.price ?? 0)}'
                                    .substring(0, 8),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 24, 12, 6),
                      child: const Text(
                        "Selecione o tipo de pagamento",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        margin:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
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
                        child: Column(
                          children: [
                            DropdownButton<String>(
                              hint: const Text('Clique aqui para selecionar'),
                              value: formaPagamentoSelecionada,
                              onChanged: (String? newValue) {
                                setState(() {
                                  formaPagamentoSelecionada = newValue;
                                });
                              },
                              items: formasPagamento.map((String forma) {
                                return DropdownMenuItem<String>(
                                  value: forma,
                                  child: Text(forma),
                                );
                              }).toList(),
                            ),
                          ],
                        )),
                    const SizedBox(
                      height: 14,
                    ),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 8, 12, 16),
                  color: Colors.white,
                  // Defina a cor de fundo desejada
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deseja finaliza seu pedido ?',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight
                              .bold, // Pode ser FontWeight.bold para negrito, se desejar
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final classe = PedidosApi();
                          final bool? pedidoEncerrado =
                              await classe.pedidoEncerrado(
                            widget.pedidoId!,
                            formaPagamentoSelecionada!,
                            widget.valorTotal!,
                            rotas.price!,
                            rotas.distance!,
                            rotas.mapUrl!,
                          );
                          if (pedidoEncerrado == true) {
                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                      'Pedido concluido com sucesso'),
                                  content: const Text(
                                      'Clique em OK para voltar à página anterior.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () async {
                                        widget.atualizarPedidos();
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // O pedido não pôde ser encerrado, você pode mostrar uma mensagem de erro aqui
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('O pedido já está encerrado'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Concluir Pedido',
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
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
