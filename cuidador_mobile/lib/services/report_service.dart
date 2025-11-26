import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_client.dart';
import '../models/pain_report.dart';

class ReportService {
  Future<PainReport> fetchPainReport(String token) async {
    final uri = Uri.parse(ApiClient.painEvolutionUrl);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PainReport.fromJson(data);
    } else {
      throw Exception('Erro ao buscar evolução da dor: '
          '${response.statusCode} ${response.body}');
    }
  }

  Future<void> sendFeedback(
    String token,
    GeneralFeedbackRequest request,
  ) async {
    final uri = Uri.parse(ApiClient.feedbackUrl);

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao enviar feedback: '
          '${response.statusCode} ${response.body}');
    }
  }
}