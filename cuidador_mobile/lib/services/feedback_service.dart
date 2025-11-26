import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/general_feedback_request.dart';
import 'api_client.dart';

class FeedbackService {
  Future<void> sendGeneralFeedback(
      String token, GeneralFeedbackRequest request) async {
    final url = Uri.parse(ApiClient.feedbackUrl);

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
  }
}