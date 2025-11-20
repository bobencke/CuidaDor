class AuthResponse {
  final String token;
  final DateTime expiresAt;

  AuthResponse({
    required this.token,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}