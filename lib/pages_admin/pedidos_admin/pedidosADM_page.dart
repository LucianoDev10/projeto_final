import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:projeto_01_teste/model/entregas/entregas_modal.dart';
import 'package:projeto_01_teste/pages_admin/pedidos_admin/pdf.dart';
import 'package:projeto_01_teste/pages_admin/pedidos_admin/pedidosADM_bloc.dart';
import 'package:projeto_01_teste/pages_admin/pedidos_admin/pedidosADM_ind.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';

import '../../utils/itens_ordenar.dart';

class PedidosADMpage extends StatefulWidget {
  const PedidosADMpage({super.key});

  @override
  State<PedidosADMpage> createState() => _PedidosADMpageState();
}

class _PedidosADMpageState extends State<PedidosADMpage> {
  final PedidosBlocADM _pedidosBloc = PedidosBlocADM();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _pedidosBloc.fetchPedidos();
  }

  Future<void> _refreshData() async {
    await _pedidosBloc.fetchPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos de Entregas'),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshData,
        child: StreamBuilder<List<Entregas>>(
          stream: _pedidosBloc.streamNotDestaque,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            List<Entregas> entregas = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: entregas.length,
                    itemBuilder: (context, index) {
                      Entregas entrega = entregas[index];
                      return GestureDetector(
                        onTap: () async {
                          final success = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PedidosADMind(
                                pedidoId: entrega.pedId!,
                                status: entrega.entStatusAdmin!,
                                atualizarPedidos: _refreshData,
                              ),
                            ),
                          );
                          if (success == true) {
                            await _refreshData();
                          }
                        },
                        child: Container(
                          margin:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white, // Cor de fundo
                            borderRadius: BorderRadius.circular(
                                10.0), // Borda arredondada
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
                              Text(
                                'ID do pedido:  ${entrega.entId.toString()}',
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: entrega.entStatusAdmin == 'Aceito'
                                      ? Border.all(
                                          color: Colors.green, width: 2.0)
                                      : Border.all(
                                          color: minhaCorPersonalizada,
                                          width: 2.0),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  'Status do pedido: ${entrega.entStatusAdmin}',
                                  style: TextStyle(
                                    color: entrega.entStatusAdmin == 'Aceito'
                                        ? Colors.green
                                        : minhaCorPersonalizada,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _createPdf(context, entregas);
                      },
                      child: Text('Baixar pdf'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await _launchURL(
                              'https://lookerstudio.google.com/reporting/5e2e72a8-8805-4b18-8350-89f746f0833c');
                        },
                        child: Text('Dashboard')),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _createPdf(context, List<Entregas> entregas) async {
    final pdfLib.Document pdf = pdfLib.Document();

    // Adiciona a página ao PDF
    pdf.addPage(
      pdfLib.Page(
        build: (context) => pdfLib.Center(
          child: pdfLib.Table.fromTextArray(
            context: context,
            data: _getPdfTableData(entregas),
          ),
        ),
      ),
    );

    final String dir = (await getApplicationDocumentsDirectory()).path;

    final String path = '$dir/pdfExample.pdf';
    final File file = File(path);

    final Uint8List bytes = await pdf.save();

    await file.writeAsBytes(bytes);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ViewPdf(
          path: path,
        ),
      ),
    );
  }

  List<List<String>> _getPdfTableData(List<Entregas> entregas) {
    // Cria uma lista de listas de strings para os dados da tabela
    List<List<String>> tableData = [
      ['ID do pedido', 'Status do pedido']
    ];

    // Adiciona os dados da lista entregas à tabela
    for (Entregas entrega in entregas) {
      tableData.add([entrega.entId.toString(), entrega.entStatusAdmin!]);
    }

    return tableData;
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link: $url';
    }
  }
}
