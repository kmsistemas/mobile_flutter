import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API Service centralizado similar ao DataModule.Geral do Delphi
/// Centraliza todas as rotas e requisições HTTP da aplicação
class ApiService {
  final String baseUrl;
  final String token;
  final String idUsuario;
  final Map<String, String> defaultHeaders;

  ApiService({
    required String baseUrl,
    required this.token,
    required this.idUsuario,
  })  : baseUrl = _normalizeBaseUrl(baseUrl),
        defaultHeaders = {
          'Content-Type': 'application/json',
          'kmapp': 'KMIND',
          'version': '2.00',
          'Authorization': 'Bearer $token',
          'id_usuario': idUsuario,
        };

  /// Remove barras finais e um eventual sufixo "/industrial" para evitar duplicar na rota.
  static String _normalizeBaseUrl(String url) {
    var cleaned = url.trim();
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    if (cleaned.toLowerCase().endsWith('/industrial')) {
      cleaned = cleaned.substring(0, cleaned.length - '/industrial'.length);
    }
    return cleaned;
  }

  /// Normaliza datas no formato dd/MM/yy para dd/MM/yyyy.
  String _normalizeDateParam(String date) {
    final trimmed = date.trim();
    final m = RegExp(r'^(\\d{2})/(\\d{2})/(\\d{2})$').firstMatch(trimmed);
    if (m != null) {
      return '${m.group(1)}/${m.group(2)}/20${m.group(3)}';
    }
    return trimmed;
  }

  /// Monta headers com o Token Bearer
  Map<String, String> _getHeaders({Map<String, String>? extra}) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  /// **BUSCAR PASSAGEM** - GET /industrial/ficha/{id_passagem}
  /// Inclui id_usuario no header (como no Delphi).
  Future<Map<String, dynamic>> buscarPassagem({
    required String idPassagem,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/industrial/ficha/$idPassagem');
      final response = await http
          .get(
            uri,
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[buscarPassagem] GET $uri');
        debugPrint('[buscarPassagem] status: ${response.statusCode}');
        debugPrint('[buscarPassagem] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty)
          return Map<String, dynamic>.from(data.first);
        if (data is Map) return Map<String, dynamic>.from(data);
        throw Exception('Formato inesperado: ${response.body}');
      } else {
        throw Exception(
            'Erro ao buscar passagem: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar passagem: $e');
    }
  }

  /// **REGISTRAR PASSAGEM** - PUT /industrial/passagem_registra/0
  /// Headers: id_pcpst, id_unidade, quantidade, id_usuario
  /// Body: jsonGrade (string, pode ser vazio)
  Future<Map<String, dynamic>> registrarPassagem({
    required String idPassagem,
    required String idUnidade,
    required String quantidade,
    String jsonGrade = '',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/industrial/passagem_registra/0');
      final headers = _getHeaders(extra: {
        'id_pcpst': idPassagem,
        'id_unidade': idUnidade,
        'quantidade': quantidade,
        'id_usuario': idUsuario,
      });
      final response = await http
          .put(uri, headers: headers, body: jsonGrade)
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[registrarPassagem] PUT $uri');
        debugPrint('[registrarPassagem] headers: ${headers.toString()}');
        debugPrint('[registrarPassagem] status: ${response.statusCode}');
        debugPrint('[registrarPassagem] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map ? Map<String, dynamic>.from(data) : {'status': 'ok'};
      } else {
        throw Exception(
            'Erro ao registrar passagem: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao registrar passagem: $e');
    }
  }

  /// **CANCELAR PASSAGEM** - PUT /industrial/passagem_cancela/{id_qtdst}
  /// Headers: id_usuario
  Future<Map<String, dynamic>> cancelarPassagem({
    required String idQtdst,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/industrial/passagem_cancela/$idQtdst');
      final headers = _getHeaders(extra: {'id_usuario': idUsuario});
      final response = await http
          .put(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[cancelarPassagem] PUT $uri');
        debugPrint('[cancelarPassagem] status: ${response.statusCode}');
        debugPrint('[cancelarPassagem] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map ? Map<String, dynamic>.from(data) : {'status': 'ok'};
      } else {
        throw Exception(
            'Erro ao cancelar passagem: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao cancelar passagem: $e');
    }
  }

  /// **LOGIN** - POST /login
  /// Body: { "User": "...", "Password": "..." }
  /// Response: { "id_usuario", "token", "grupo", "vappkmind", "cperocoindus", "vtpappkmind" }
  Future<Map<String, dynamic>> login({
    required String user,
    required String password,
  }) async {
    try {
      final body = {
        'User': user.toUpperCase(),
        'Password': password.toUpperCase(),
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'kmapp': 'KMIND',
              'version': '2.00',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Credenciais inválidas');
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **LISTAR GRUPOS INDUSTRIAIS** - GET /industrial/grupo
  /// Retorna lista de grupos do usuário
  Future<List<dynamic>> listarGrupoIndustrial() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/industrial/grupo'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[listarGrupoIndustrial] GET $baseUrl/industrial/grupo');
        debugPrint('[listarGrupoIndustrial] status: ${response.statusCode}');
        debugPrint('[listarGrupoIndustrial] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [data];
      } else {
        throw Exception('Erro ao listar grupos: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **LISTAR SETORES** - GET /industrial/setor_usuario/{id_grupo}
  Future<List<dynamic>> listarSetorIndustrial({required String idGrupo}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/industrial/setor_usuario/$idGrupo'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[listarGrupoIndustrial] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [data];
      } else {
        throw Exception('Erro ao listar setores: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **LISTAR UNIDADES PRODUTIVAS** - GET /industrial/up ou GET /industrial/up_usuario/{id_setor}
  Future<List<dynamic>> listarUnidadeProdutiva({String? idSetor}) async {
    try {
      final endpoint = (idSetor == null || idSetor.isEmpty || idSetor == '00')
          ? '$baseUrl/industrial/up'
          : '$baseUrl/industrial/up_usuario/$idSetor';

      final response = await http
          .get(
            Uri.parse(endpoint),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [data];
      } else {
        throw Exception('Erro ao listar unidades: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **LISTAR ORDENS DE SERVIÇO** - GET /os/{setor}
  Future<List<dynamic>> listarOS({
    required String setor,
    required String idUp,
    required String idFicha,
    required String codFicha,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/industrial/os/$setor');

      final response = await http
          .get(
            uri,
            headers: _getHeaders(extra: {
              'id_up': idUp,
              'id_ficha': idFicha,
              'cod_ficha': codFicha,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[listarOS] GET $uri');
        debugPrint('[listarOS] status: ${response.statusCode}');
        debugPrint('[listarOS] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [data];
      } else {
        throw Exception(
            'Erro ao listar OS: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao listar OS: $e');
    }
  }

  /// **LISTAR COLETAS** - GET /coleta/{id}
  Future<List<dynamic>> listarColeta({
    required String idUp,
    required String dataColeta,
  }) async {
    try {
      final uri =
          Uri.parse('$baseUrl/industrial/coleta/0').replace(queryParameters: {
        'id_os': '0',
        'id_up': idUp,
        'data_coleta': dataColeta,
      });

      final response = await http
          .get(
            uri,
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[listarColeta] GET $uri');
        debugPrint('[listarColeta] status: ${response.statusCode}');
        debugPrint('[listarColeta] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [data];
      } else {
        throw Exception(
            'Erro ao listar coletas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao listar coletas: $e');
    }
  }

  /// **LISTAR ESTOQUE** - GET /estoque/{codigo}
  Future<Map<String, dynamic>> listarEstoque({required String codigo}) async {
    try {
      final uri = Uri.parse('$baseUrl/industrial/estoque/$codigo');
      final headers = _getHeaders(extra: {'codigo': codigo});
      final response = await http
          .get(
            uri,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[listarEstoque] GET $uri');
        debugPrint('[listarEstoque] status: ${response.statusCode}');
        debugPrint('[listarEstoque] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erro ao listar estoque: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao listar estoque: $e');
    }
  }

  /// **LISTAR INVENTÁRIO** - GET /inventario/{codigo}
  Future<Map<String, dynamic>> listarInventario(
      {required String codigo}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/industrial/inventario/$codigo'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao listar inventário: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **LISTAR INVENTÁRIO (industrial prefix)** - GET /industrial/inventario/{codigo}
  Future<Map<String, dynamic>> listarInventarioIndustrial(
      {required String codigo}) async {
    try {
      final uri = Uri.parse('$baseUrl/industrial/inventario/$codigo');
      final response = await http
          .get(
            uri,
            headers: _getHeaders(extra: {'codigo': codigo}),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[listarInventarioIndustrial] GET $uri');
        debugPrint(
            '[listarInventarioIndustrial] status: ${response.statusCode}');
        debugPrint('[listarInventarioIndustrial] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erro ao listar inventário: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao listar inventário: $e');
    }
  }

  /// **LISTAR ITENS DO INVENTÁRIO** - GET /industrial/inventario/itens/{codigo}
  /// Headers: codigo (filtro opcional), page (opcional)
  Future<Map<String, dynamic>> listarItensInventario({
    required String codigoInventario,
    String codigoProduto = '',
    int page = 1,
  }) async {
    try {
      final uri =
          Uri.parse('$baseUrl/industrial/inventario/itens/$codigoInventario');
      final response = await http
          .get(
            uri,
            headers: _getHeaders(extra: {
              'codigo': codigoProduto,
              'page': page.toString(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[listarItensInventario] GET $uri');
        debugPrint('[listarItensInventario] status: ${response.statusCode}');
        debugPrint('[listarItensInventario] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erro ao listar itens inventário: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao listar itens inventário: $e');
    }
  }

  /// **BUSCAR FICHA POR ID** - GET /ficha/{id_ficha}
  Future<Map<String, dynamic>> buscarFicha({required String idFicha}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/industrial/ficha/$idFicha'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar ficha: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **REGISTRAR ENTRADA** - PUT /industrial/ficha_entrada/{id_passagem}
  Future<Map<String, dynamic>> registrarEntrada({
    required String idPassagem,
    required String dataEntrada,
  }) async {
    try {
      final dt = _normalizeDateParam(dataEntrada);
      if (kDebugMode) {
        debugPrint('[registrarEntrada] PUT $baseUrl/industrial/ficha_entrada/$idPassagem');
        debugPrint('[registrarEntrada] headers dt_entrada=$dt id_usuario=$idUsuario');
      }
      final headers = _getHeaders();
      headers['dt_entrada'] = dt;
      headers['id_usuario'] = idUsuario;
      final response = await http
          .put(
            Uri.parse('$baseUrl/industrial/ficha_entrada/$idPassagem'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao registrar entrada: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **CANCELAR ENTRADA** - PUT /industrial/ficha_cancela_entrada/{id_passagem}
  Future<Map<String, dynamic>> cancelarEntrada({
    required String idPassagem,
    required String dataEntrada,
  }) async {
    try {
      final dt = _normalizeDateParam(dataEntrada);
      if (kDebugMode) {
        debugPrint('[cancelarEntrada] PUT $baseUrl/industrial/ficha_cancela_entrada/$idPassagem');
        debugPrint('[cancelarEntrada] headers dt_entrada=$dt id_usuario=$idUsuario');
      }
      final headers = _getHeaders();
      headers['dt_entrada'] = dt;
      headers['id_usuario'] = idUsuario;

      final response = await http
          .put(
            Uri.parse('$baseUrl/industrial/ficha_cancela_entrada/$idPassagem'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao cancelar entrada: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **REGISTRAR COLETA** - PUT /coleta_registra/{id_coleta}
  Future<Map<String, dynamic>> registrarColeta({
    required String idColeta,
    required String tipo,
  }) async {
    try {
      final headers = _getHeaders();
      headers['tipo'] = tipo;

      final response = await http
          .put(
            Uri.parse('$baseUrl/industrial/coleta_registra/$idColeta'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao registrar coleta: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **REGISTRAR OCORRÊNCIA** - PUT /ocorrencia_registra
  Future<Map<String, dynamic>> registrarOcorrencia({
    required String idPassagem,
    required String idTpOcorr,
    required String idUnidade,
    required String quantidade,
    required String idGrade,
    required String grade,
    required String observacao,
  }) async {
    try {
      final body = {
        'id_passagem': idPassagem,
        'id_tpocorr': idTpOcorr,
        'id_unidade': idUnidade,
        'quantidade': quantidade,
        'id_grade': idGrade,
        'grade': grade,
        'observacao': observacao,
        'id_usuario': idUsuario,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/industrial/ocorrencia_registra'),
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao registrar ocorrência: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **BUSCAR IMAGEM** - GET /img/{id_item_pedido}
  Future<List<int>> buscarImagem({required String idItemPedido}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/industrial/img/$idItemPedido'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Erro ao buscar imagem: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **LISTAR TIPOS DE OCORRÊNCIA** - GET /tpocorrencia
  Future<List<dynamic>> listarTpOcorrencia() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/industrial/tpocorrencia'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [data];
      } else {
        throw Exception(
            'Erro ao listar tipos de ocorrência: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// **LISTAR TODAS AS FICHAS** - GET /todas_fichas
  /// Com filtros opcionais por data, situação, produto, grupo
  Future<List<dynamic>> listarTodasFichas({
    required String porData,
    required String dataIni,
    required String dataFim,
    required String situacao,
    required String produto,
    required String grupoInd,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/industrial/todas_fichas')
          .replace(queryParameters: {
        'pordata': porData,
        'dataini': dataIni,
        'datafim': dataFim,
        'situacao': situacao,
        'produto': produto,
        'grupoind': grupoInd,
      });

      final response = await http
          .get(
            uri,
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [data];
      } else {
        throw Exception('Erro ao listar fichas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
