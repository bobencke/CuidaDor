import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/auth_response.dart';
import '../models/register_request.dart';
import 'api_client.dart';
import 'local_cache_service.dart';

class AuthService {
  final _cache = LocalCacheService.instance;

  Future<AuthResponse> login(String email, String password) async {
    final url = Uri.parse(ApiClient.loginUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(_extractMessage(response));
      }
    } catch (_) {
      // fallback offline
      return _cache.loginOffline(email, password);
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final url = Uri.parse(ApiClient.registerUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(_extractMessage(response));
      }
    } catch (_) {
      // fallback offline
      return _cache.registerOffline(request);
    }
  }

  String _extractMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return 'Erro ao comunicar com o servidor (${response.statusCode})';
  }
}
