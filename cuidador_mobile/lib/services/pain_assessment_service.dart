import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pain_assessment_request.dart';
import 'api_client.dart';

class PainAssessmentService {
  Future<void> createAssessment(
      String token, PainAssessmentRequest request) async {
    final url = Uri.parse(ApiClient.painAssessmentUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao salvar avaliação da dor '
          '(${response.statusCode})');
    }
  }
}