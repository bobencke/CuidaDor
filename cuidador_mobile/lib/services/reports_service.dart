import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pain_report.dart';
import '../models/user_data_export.dart';
import 'api_client.dart';
import 'local_cache_service.dart';

class ReportsService {
  final _cache = LocalCacheService.instance;

  Future<PainReport> getPainReport(String token, {int days = 7}) async {
    final url = Uri.parse('${ApiClient.painReportUrl}?days=$days');

    try {
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
        throw Exception('Erro ao carregar relatorio de dor '
            '(${response.statusCode})');
      }
    } catch (_) {
      return _cache.getPainReport(token, days: days);
    }
  }

  Future<UserDataExport> getUserDataExport(String token) async {
    final url = Uri.parse(ApiClient.userDataExportUrl);

    try {
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
        throw Exception('Erro ao carregar export de dados do usuario '
            '(${response.statusCode})');
      }
    } catch (_) {
      return _cache.getUserDataExport(token);
    }
  }

  Future<List<UserDataExport>> getAllUsersDataExport(String token) async {
    final url = Uri.parse(ApiClient.allUsersDataExportUrl);

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
                  UserDataExport.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Resposta inesperada do export geral.');
        }
      } else {
        throw Exception(
          'Erro ao carregar export de todos os usuarios '
          '(${response.statusCode})',
        );
      }
    } catch (_) {
      return _cache.getAllUsersDataExport();
    }
  }
}
