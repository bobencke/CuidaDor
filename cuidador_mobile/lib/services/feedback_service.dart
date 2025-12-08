import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/general_feedback_request.dart';
import 'api_client.dart';
import 'local_cache_service.dart';

class FeedbackService {
  final _cache = LocalCacheService.instance;

  Future<void> sendGeneralFeedback(
      String token, GeneralFeedbackRequest request) async {
    final url = Uri.parse(ApiClient.feedbackUrl);

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
          'Erro ao enviar feedback (${response.statusCode})',
        );
      }
    } catch (_) {
      await _cache.sendGeneralFeedback(token, request);
    }
  }
}
