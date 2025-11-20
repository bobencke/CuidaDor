class RegisterRequest {
  final String fullName;
  final int age;
  final String sex;
  final String phoneNumber;
  final String email;
  final String password;
  final List<String> comorbidities;
  final double fontScale;
  final bool highContrast;
  final bool voiceReading;
  final bool consentLgpd;

  RegisterRequest({
    required this.fullName,
    required this.age,
    required this.sex,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.comorbidities,
    required this.fontScale,
    required this.highContrast,
    required this.voiceReading,
    required this.consentLgpd,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'age': age,
      'sex': sex,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'comorbidities': comorbidities,
      'fontScale': fontScale,
      'highContrast': highContrast,
      'voiceReading': voiceReading,
      'consentLgpd': consentLgpd,
    };
  }
}