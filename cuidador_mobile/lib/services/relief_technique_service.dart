import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/relief_technique.dart';
import '../models/technique_session_request.dart';
import 'api_client.dart';

class ReliefTechniqueService {
  Future<List<ReliefTechniqueListItem>> getTechniques(String token) async {
    final url = Uri.parse(ApiClient.reliefTechniquesUrl);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body
            .map((e) =>
                ReliefTechniqueListItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Resposta inesperada da API de técnicas.');
      }
    } else {
      throw Exception('Erro ao carregar técnicas (${response.statusCode})');
    }
  }

  Future<ReliefTechniqueDetail> getTechniqueDetail(
      String token, int id) async {
    final url = Uri.parse(ApiClient.reliefTechniqueDetailUrl(id));

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      return ReliefTechniqueDetail.fromJson(body as Map<String, dynamic>);
    } else {
      throw Exception('Erro ao carregar detalhes da técnica '
          '(${response.statusCode})');
    }
  }

  Future<void> registerSession(
      String token, TechniqueSessionRequest request) async {
    final url = Uri.parse(ApiClient.reliefTechniqueSessionUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao registrar sessão da técnica (${response.statusCode})',
      );
    }
  }
}