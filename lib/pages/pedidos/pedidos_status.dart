import 'package:flutter/material.dart';
import 'package:projeto_01_teste/model/entregas/entregas_modal.dart';
import 'package:projeto_01_teste/pages/pedidos/pedidos_api.dart';

class PedidoStatus extends StatefulWidget {
  final Function() atualizarPedidos;
  final int? pedidoId;

  PedidoStatus({
    Key? key,
    required this.atualizarPedidos,
    required this.pedidoId,
  }) : super(key: key);

  @override
  _PedidoStatusState createState() => _PedidoStatusState();
}

class _PedidoStatusState extends State<PedidoStatus> {
  late Future<Entregas?> _StatusDetails;

  @override
  void initState() {
    super.initState();
    _StatusDetails = PedidosApi.Status(widget.pedidoId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Status do pedido'),
        ),
        body: FutureBuilder<Entregas?>(
            future: _StatusDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (!snapshot.hasData) {
                return const Text('Nenhum detalhe encontrado');
              } else {
                Entregas entregas = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 18,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Status do seu pedido:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.yellow, // Cor de fundo
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
                      child: entregas.entStatusAdmin == 'Pendente'
                          ? const Text(
                              'O supermercado está preparando seu pedido!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : const Text(
                              'O pedido já foi despachado pelo supermercado!',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Container(
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
                        child: entregas.entStatusEntregador == 'Pendente'
                            ? Column(
                                children: [
                                  const Text(
                                      'O entregador está indo a caminho do seu pedido',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Image.asset(
                                    'assets/images/entregas-bg.png',
                                    height: 150,
                                    width: double.infinity,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const Text('Entrega realizada!!!',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Image.asset(
                                    'assets/images/check.png',
                                    height: 150,
                                    width: double.infinity,
                                  ),
                                ],
                              ))
                  ],
                );
              }
            }));
  }
}
