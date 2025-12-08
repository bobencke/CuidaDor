import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/relief_technique.dart';
import '../models/technique_session_request.dart';
import 'api_client.dart';
import 'local_cache_service.dart';

class ReliefTechniqueService {
  final _cache = LocalCacheService.instance;

  Future<List<ReliefTechniqueListItem>> getTechniques(String token) async {
    final url = Uri.parse(ApiClient.reliefTechniquesUrl);

    try {
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
          throw Exception('Resposta inesperada da API de tecnicas.');
        }
      } else {
        throw Exception('Erro ao carregar tecnicas (${response.statusCode})');
      }
    } catch (_) {
      return _cache.getTechniques();
    }
  }

  Future<ReliefTechniqueDetail> getTechniqueDetail(
      String token, int id) async {
    final url = Uri.parse(ApiClient.reliefTechniqueDetailUrl(id));

    try {
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
        throw Exception('Erro ao carregar detalhes da tecnica '
            '(${response.statusCode})');
      }
    } catch (_) {
      return _cache.getTechniqueDetail(id);
    }
  }

  Future<void> registerSession(
      String token, TechniqueSessionRequest request) async {
    final url = Uri.parse(ApiClient.reliefTechniqueSessionUrl);

    try {
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
          'Erro ao registrar sessao da tecnica (${response.statusCode})',
        );
      }
    } catch (_) {
      await _cache.registerTechniqueSession(token, request);
    }
  }
}
