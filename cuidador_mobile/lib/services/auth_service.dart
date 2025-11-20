import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/auth_response.dart';
import '../models/register_request.dart';
import 'api_client.dart';

class AuthService {
  Future<AuthResponse> login(String email, String password) async {
    final url = Uri.parse(ApiClient.loginUrl);

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
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final url = Uri.parse(ApiClient.registerUrl);

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