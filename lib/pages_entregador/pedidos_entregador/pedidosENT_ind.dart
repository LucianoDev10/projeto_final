import 'package:flutter/material.dart';
import 'package:projeto_01_teste/pages_entregador/pedidos_entregador/pedidosENT_api.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/entregas/entregas_modal.dart';

class PedidosENTind extends StatefulWidget {
  final int entId;
  final int pedidoId;

  final String status;
  final Function() atualizarPedidos;

  PedidosENTind({
    Key? key,
    required this.entId,
    required this.pedidoId,
    required this.status,
    required this.atualizarPedidos,
  }) : super(key: key);

  @override
  _PedidosENTindState createState() => _PedidosENTindState();
}

class _PedidosENTindState extends State<PedidosENTind> {
  late Future<Entregas?> _pedidoDetails;
  final PedidosENTapi apiService = PedidosENTapi();
  TextEditingController _minutosController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _pedidoDetails = PedidosENTapi.getPedidoIndividual(widget.entId);
  }

  Future<void> _refreshData() async {
    _pedidoDetails = PedidosENTapi.getPedidoIndividual(widget.entId);
  }

  Future<void> atualizarPedidos() async {
    _pedidoDetails = PedidosENTapi.getPedidoIndividual(widget.entId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da entrega'),
      ),
      body: FutureBuilder<Entregas?>(
        future: _pedidoDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (!snapshot.hasData) {
            return const Text('Nenhum detalhe encontrado');
          } else {
            Entregas detalhes = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                    child: const Text(
                      "Informações sobre o cliente:",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
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
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Estilo do texto fixo
                            children: [
                              const TextSpan(
                                text: 'ID do pedido: ',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold), // Estilo do texto fixo
                              ),
                              TextSpan(
                                text: detalhes.entId.toString(), // Variável
                                style: const TextStyle(
                                    fontWeight: FontWeight
                                        .normal), // Estilo da variável
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Estilo do texto fixo
                            children: [
                              const TextSpan(
                                text: 'CEP: ',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold), // Estilo do texto fixo
                              ),
                              TextSpan(
                                text: detalhes.usuCep, // Variável
                                style: const TextStyle(
                                    fontWeight: FontWeight
                                        .normal), // Estilo da variável
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            children: <TextSpan>[
                              const TextSpan(
                                text: 'Rua: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: detalhes.usuEndereco ?? 'N/A',
                              ),
                              TextSpan(
                                text: ', ${detalhes.usuNumero ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Estilo do texto fixo
                            children: [
                              const TextSpan(
                                text: 'Nome do cliente: ',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold), // Estilo do texto fixo
                              ),
                              TextSpan(
                                text: detalhes.usuNome, // Variável
                                style: const TextStyle(
                                    fontWeight: FontWeight
                                        .normal), // Estilo da variável
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Estilo do texto fixo
                            children: [
                              const TextSpan(
                                text: 'Telefone do cliente: ',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold), // Estilo do texto fixo
                              ),
                              TextSpan(
                                text: detalhes.usuTelefone, // Variável
                                style: const TextStyle(
                                    fontWeight: FontWeight
                                        .normal), // Estilo da variável
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Estilo do texto fixo
                            children: [
                              TextSpan(
                                text: 'Status do supermercado: ',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold), // Estilo do texto fixo
                              ),
                              TextSpan(
                                text: 'Despachado',
                                style: TextStyle(
                                    color: Colors
                                        .white, // Estilo para o valor da variável "Status"
                                    fontWeight: FontWeight.bold,
                                    backgroundColor: Colors.green,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: const Text(
                      "Informações sobre a entrega:",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 0.0),
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
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Estilo do texto fixo
                            children: [
                              const TextSpan(
                                text: 'Valor do pedido: ',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold), // Estilo do texto fixo
                              ),
                              TextSpan(
                                text: detalhes.pedValorTotal
                                    .toString(), // Variável
                                style: const TextStyle(
                                    fontWeight: FontWeight
                                        .normal), // Estilo da variável
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Estilo do texto fixo
                            children: [
                              const TextSpan(
                                text: 'Valor do frete: ',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold), // Estilo do texto fixo
                              ),
                              TextSpan(
                                text: detalhes.pedFrete.toString(), // Variável
                                style: const TextStyle(
                                    fontWeight: FontWeight
                                        .normal), // Estilo da variável
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Estilo do texto fixo
                            children: [
                              const TextSpan(
                                text: 'Tipo de Pagamento ',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold), // Estilo do texto fixo
                              ),
                              TextSpan(
                                text: detalhes.pedTipoPagamento, // Variável
                                style: const TextStyle(
                                    fontWeight: FontWeight
                                        .normal), // Estilo da variável
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Estilo do texto fixo
                            children: [
                              const TextSpan(
                                text: 'Distancia da entrega: ',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold), // Estilo do texto fixo
                              ),
                              TextSpan(
                                text: detalhes.pedDistancia.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight
                                        .normal), // Estilo da variável
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
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
                        children: [
                          const Text(
                              'Digite aqui em minutos qual tempo para entrega:'),
                          const SizedBox(
                            height: 16,
                          ),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _minutosController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: 'Digite os minutos',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo é obrigatório';
                                }
                                return null;
                              },
                            ),
                          )
                        ],
                      )),
                  ElevatedButton(
                    onPressed: () async {
                      String mapUrl = detalhes.pedRota ?? "";
                      _launchURL(mapUrl);
                      print(mapUrl);
                    },
                    child: const Text('Rota da entrega'),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 8, 12, 16),
                    color: Colors.white,
                    // Defina a cor de fundo desejada
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Clique para saber os valores:',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight
                                .bold, // Pode ser FontWeight.bold para negrito, se desejar
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // O formulário é válido, prossiga com o envio dos dados.
                              String minutosInseridos = _minutosController.text;
                              final classe = PedidosENTapi();
                              await classe.aceitarEntrega(
                                  widget.entId,
                                  int.parse(minutosInseridos),
                                  detalhes.pedFrete!);

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Entrega aceita com sucesso'),
                                    content: Text(
                                        'Clique em OK para voltar ao seu pedido.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
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
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Adicione os dados faltantes'),
                                    content: Text(
                                        'Clique em OK para voltar ao seu pedido.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () async {
                                          Navigator.pop(context, true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: const Text(
                            'Aceitar Entrega',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link: $url';
    }
  }
}
