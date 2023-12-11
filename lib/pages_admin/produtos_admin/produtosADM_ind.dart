import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:projeto_01_teste/pages_admin/produtos_admin/produtosADM_api.dart';

class ProdutoADMind extends StatefulWidget {
  final int catId;
  final int? proId;
  final Function()? atualizarPedidos;

  ProdutoADMind(
      {Key? key, required this.catId, this.proId, this.atualizarPedidos})
      : super(key: key);

  @override
  _ProdutoADMindState createState() => _ProdutoADMindState(catId, proId);
}

class _ProdutoADMindState extends State<ProdutoADMind> {
  final int catId;
  final int? proId;
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final MaskTextInputFormatter _precoFormatter =
      MaskTextInputFormatter(mask: '##.#######.##');

  final TextEditingController _fotoController = TextEditingController();
  final TextEditingController _subDescricaoController = TextEditingController();
  File? _image; // Variável para armazenar a foto selecionada

  _ProdutoADMindState(this.catId, this.proId);

  @override
  void initState() {
    super.initState();
    _atualizarProdutoData();
  }

  Future<void> _atualizarProdutoData() async {
    final produtoService = produtosADMapi();

    if (widget.proId != null) {
      final produtoId = widget.proId;
      final produtoAtualizado =
          await produtoService.getDetalhesProduto(produtoId!);

      if (produtoAtualizado != null) {
        setState(() {
          _descricaoController.text = produtoAtualizado.pro_descricao ?? '';
          _precoController.text = produtoAtualizado.pro_preco.toString() ?? '';
          _fotoController.text = produtoAtualizado.pro_foto ?? '';
          _subDescricaoController.text =
              produtoAtualizado.pro_subDescricao ?? '';
        });
      }
    }
  }

  Future<void> _atualizarProduto() async {
    String descricao = _descricaoController.text;
    String preco = _precoController.text;

    String foto = _fotoController.text;
    String subDescricao = _subDescricaoController.text;

    final bool? response;

    if (widget.proId != null) {
      response = await produtosADMapi.atualizarProduto(
          widget.proId!, descricao, double.parse(preco), foto, subDescricao);
    } else {
      response = await produtosADMapi.criarProduto(
          widget.catId, descricao, double.parse(preco), foto, subDescricao);
    }

    if (response == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Produto alterado com sucesso'),
            content: const Text('Clique em OK para voltar ao seu pedido.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  widget.atualizarPedidos!();

                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar o produto'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Criar/Editar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição do Produto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              controller: _precoController,
              inputFormatters: [_precoFormatter],
              decoration: const InputDecoration(
                labelText: 'Preço do Produto',
                prefixIcon:
                    Icon(Icons.attach_money), // Ícone de dinheiro como exemplo
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fotoController,
                    decoration: const InputDecoration(
                      labelText: 'URL da Foto',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                ElevatedButton(
                  onPressed: _selectImage,
                  child: Text('Selecionar Imagem'),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              controller: _subDescricaoController,
              decoration: const InputDecoration(
                labelText: 'Subdescrição do Produto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _atualizarProduto,
              child: const Text('Salvar Produto'),
            ),
          ],
        ),
      ),
    );
  }
}
