import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pain_report.dart';
import 'api_client.dart';

class ReportsService {
  Future<PainReport> getPainReport(String token, {int days = 7}) async {
    final url = Uri.parse('${ApiClient.painReportUrl}?days=$days');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      return PainReport.fromJson(body as Map<String, dynamic>);
    } else {
      throw Exception('Erro ao carregar relatório de dor '
          '(${response.statusCode})');
    }
  }
}