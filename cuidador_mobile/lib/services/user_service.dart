import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/update_user_profile_request.dart';
import '../models/user_profile.dart';
import 'api_client.dart';

class UserService {
  Future<UserProfile> getProfile(String token) async {
    final url = Uri.parse(ApiClient.userMeUrl);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      return UserProfile.fromJson(body as Map<String, dynamic>);
    } else {
      throw Exception(
          'Erro ao carregar perfil (${response.statusCode})');
    }
  }

  Future<UserProfile> updateProfile(
    String token,
    UpdateUserProfileRequest request,
  ) async {
    final url = Uri.parse(ApiClient.userMeUrl);

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      return UserProfile.fromJson(body as Map<String, dynamic>);
    } else {
      throw Exception(
          'Erro ao atualizar perfil (${response.statusCode})');
    }
  }
}