import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ViewPdf extends StatelessWidget {
  final String path;

  ViewPdf({required this.path});

  void _sharePdf(BuildContext context) async {
    try {
      // Verifica se o arquivo existe antes de tentar compartilhar
      if (await File(path).exists()) {
        ShareExtend.share(
          path,
          'file',
          sharePanelTitle: 'Enviar PDF',
          subject: 'example-pdf',
        );
      } else {
        // Se o arquivo não existir, exibe um aviso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('O arquivo PDF não foi encontrado.'),
          ),
        );
      }
    } catch (e) {
      // Trata qualquer exceção que possa ocorrer durante o compartilhamento
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao compartilhar o PDF: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos PDF'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.black,
              ),
              iconSize: 30,
              onPressed: () => _sharePdf(context),
            ),
          ),
        ],
      ),
      body: PDFView(
        filePath: path,
        autoSpacing: true,
        enableSwipe: true,
        pageSnap: true,
        swipeHorizontal: true,
        pageFling: true,
      ),
    );
  }
}
