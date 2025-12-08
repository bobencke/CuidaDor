import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pain_assessment_request.dart';
import 'api_client.dart';
import 'local_cache_service.dart';

class PainAssessmentService {
  final _cache = LocalCacheService.instance;

  Future<void> createAssessment(
      String token, PainAssessmentRequest request) async {
    final url = Uri.parse(ApiClient.painAssessmentUrl);

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
        throw Exception('Erro ao salvar avaliacao da dor '
            '(${response.statusCode})');
      }
    } catch (_) {
      await _cache.addPainAssessment(token, request);
    }
  }
}
