import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pain_report.dart';
import '../models/user_data_export.dart';
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

  Future<UserDataExport> getUserDataExport(String token) async {
    final url = Uri.parse(ApiClient.userDataExportUrl);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      return UserDataExport.fromJson(body as Map<String, dynamic>);
    } else {
      throw Exception('Erro ao carregar export de dados do usuário '
          '(${response.statusCode})');
    }
  }

  Future<List<UserDataExport>> getAllUsersDataExport(String token) async {
    final url = Uri.parse(ApiClient.allUsersDataExportUrl);

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
                UserDataExport.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Resposta inesperada do export geral.');
      }
    } else {
      throw Exception(
        'Erro ao carregar export de todos os usuários '
        '(${response.statusCode})',
      );
    }
  }

}