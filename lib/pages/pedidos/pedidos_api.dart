import 'dart:convert';
import 'package:projeto_01_teste/model/entregas/entregas_modal.dart';
import 'package:projeto_01_teste/model/usuarios/usuario2_model.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_01_teste/utils/url.dart';
import '../../model/entregas/rotas_modal.dart';
import '../../model/pedidos/pedidos_modal.dart';
import '../../model/pedidos/pedidos_query_modal.dart';

class PedidosApi {
  static Future<List<Pedidos>> getPedidos() async {
    var user = await Usuario2.get();
    // var user2 = user?.usuId ?? '';
    var url = ('$apiUrl/pedidos/${user!.usuId}');
    // var url = ('http://192.168.0.70:3000/pedidos/${user!.usuId}');
    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        return []; // Retorna uma lista vazia em caso de erro
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['response'];
        print(data);

        List<Pedidos> produtosList = List<Pedidos>.from(
            data.map((produto) => Pedidos.fromJson(produto)));

        print("deu certo");
        print(produtosList);
        return produtosList;
      }

      print('Erro ${response.statusCode}: ${response.reasonPhrase}');
      return []; // Retorna uma lista vazia em caso de erro
    } catch (e) {
      print('Erro na requisição: $e');
      return []; // Retorna uma lista vazia em caso de exceção
    }
  }

// AQUI SEMPRE RETORNA UM PEDIDO EM ANDAMENTO
  static Future<Pedidos?> getPedidoEmAndamento() async {
    var user = await Usuario2.get();
    // var url =('http://192.168.0.70:3000/pedidos/pedidoAndamento/${user!.usuId}');
    var url = ('$apiUrl/pedidos/pedidoAndamento/${user!.usuId}');

    try {
      var response = await http.post(Uri.parse(url));
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> pedidoData = data['pedido'];
        final Pedidos pedido = Pedidos.fromJson(pedidoData);
        return pedido;
      } else if (response.statusCode == 404) {
        // Se não houver um pedido em andamento, retorne null
        return null;
      } else {
        // Handle outros códigos de status de acordo com sua API
        throw Exception('');
      }
    } catch (e) {
      // Handle erros de requisição, como conexão perdida, etc.
      throw Exception('Erro ao buscar pedido em andamento: $e');
    }
  }

// AQUI ADICIONAMOS UM PRODUTO AO PEDIDO
  static Future<bool?> adicionarProdutoAoPedido(
      int pedidoId, int produtoId) async {
    //var url =('http://192.168.0.70:3000/pedidos/produtos/$pedidoId/$produtoId');
    var url = ('$apiUrl/pedidos/produtos/$pedidoId/$produtoId');

    try {
      var response = await http.post(Uri.parse(url));
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        // Se não houver um pedido em andamento, retorne null
        return false;
      } else {
        // Handle outros códigos de status de acordo com sua API
        throw Exception('Erro ao buscar pedido em andamento');
      }
    } catch (e) {
      // Handle erros de requisição, como conexão perdida, etc.
      throw Exception('Erro ao adicionar pedido: $e');
    }
  }

// AQUI RETORNAMOS OS DADOS DOS PEDIDOS
  Future<List<ProdutoQuery>> getPedidosQuery(int pedidoId) async {
    var url = ('$apiUrl/pedidos/pedidosInd/$pedidoId');
    print(url);
    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        return []; // Retorna uma lista vazia em caso de erro
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Modificação: Acesse o objeto "pedido" que contém a lista de pedidos
        List<dynamic> data = jsonResponse['pedido'];

        List<ProdutoQuery> produtosList = List<ProdutoQuery>.from(
          data.map((produto) => ProdutoQuery.fromJson(produto)),
        );

        return produtosList;
      }

      print('Erro ${response.statusCode}: ${response.reasonPhrase}');
      return []; // Retorna uma lista vazia em caso de erro
    } catch (e) {
      print('Erro na requisição: $e');
      return []; // Retorna uma lista vazia em caso de exceção
    }
  }

//AQUI VAMOS FAZER O TIPO DE PAGAMENTO

  static Future<Rota?> calcularRota() async {
    final url = '$apiUrl/frete';
    var user = await Usuario2.get();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    String cepSupermerado = "12070100";

    final Map<String, String> queryParameters = {
      'PrimeiroEndereco': cepSupermerado,
      'SegundoEndereco': user!.cep ?? "",
    };

    try {
      String requestBodyJson = json.encode(queryParameters);
      final response = await http.post(Uri.parse(url),
          body: requestBodyJson, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return Rota.fromJson(jsonResponse);
      } else {
        print('Erro ${response.statusCode}: ${response.reasonPhrase}');
        // Retorna uma instância vazia de Rota em caso de erro
        return Rota(distance: null, price: null, mapUrl: null);
      }
    } catch (e) {
      print('Erro na requisição: $e');
      // Retorna uma instância vazia de Rota em caso de exceção
      return Rota(distance: null, price: null, mapUrl: null);
    }
  }

// AQUI CONCLUIMOS UM PEDIDO
  Future<bool?> pedidoEncerrado(int pedidoId, String tipoPagamento,
      double valorTotal, double frete, String distancia, String rotas) async {
    var url = ('$apiUrl/pedidos/pedidoEncerrado/$pedidoId');

    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    Map<String, dynamic> requestBody = {
      "ped_TipoPagamento": tipoPagamento,
      "ped_valorTotal": valorTotal,
      "ped_frete": frete,
      "ped_distancia": distancia,
      "ped_rota": rotas,
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        return false;
      } else if (response.statusCode == 400) {
        print('O pedido já está encerrado');
        return false;
      } else if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ${response.statusCode}: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print('Erro na requisição: $e');
      return false;
    }
  }

  Future<bool?> PedidoProdutoExcluido(
      int PPid, int PedidoId, int produtoId) async {
    //  var url =('http://192.168.0.70:3000/produtos/excluirProduto/$PPid/$PedidoId/$produtoId');
    var url = ('$apiUrl/produtos/excluirProduto/$PPid/$PedidoId/$produtoId');

    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    try {
      var response = await http.post(Uri.parse(url), headers: headers);
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        return false; // Retorna uma lista vazia em caso de erro
      }
      if (response.statusCode == 400) {
        print('O pedido já está encerrado');
        return false; // Retorna uma lista vazia em caso de erro
      }
      if (response.statusCode == 202) {
        return true;
      }

      print('Erro ${response.statusCode}: ${response.reasonPhrase}');
      return false; // Retorna uma lista vazia em caso de erro
    } catch (e) {
      print('Erro na requisição: $e');
      return false; // Retorna uma lista vazia em caso de exceção
    }
  }

  static Future<Entregas?> Status(int pedidoId) async {
    var url = ('$apiUrl/pedidos/status/$pedidoId');

    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        return null; // Retorna null em caso de erro
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        Map<String, dynamic> data = jsonResponse['response'];

        Entregas entrega = Entregas.fromJson(data);
        return entrega;
      }

      print('Erro ${response.statusCode}: ${response.reasonPhrase}');
      return null; // Retorna null em caso de erro
    } catch (e) {
      print('Erro na requisição: $e');
      return null; // Retorna null em caso de exceção
    }
  }
}
