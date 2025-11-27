class UpdateUserProfileRequest {
  final String fullName;
  final int? age;
  final String? sex;
  final String? phoneNumber;
  final List<String> comorbidities;
  final double fontScale;
  final bool highContrast;
  final bool voiceReading;
  final bool acceptLgpd;

  UpdateUserProfileRequest({
    required this.fullName,
    this.age,
    this.sex,
    this.phoneNumber,
    required this.comorbidities,
    required this.fontScale,
    required this.highContrast,
    required this.voiceReading,
    required this.acceptLgpd,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'age': age,
      'sex': sex,
      'phoneNumber': phoneNumber,
      'comorbidities': comorbidities,
      'accessibility': {
        'fontScale': fontScale,
        'highContrast': highContrast,
        'voiceReading': voiceReading,
      },
      'acceptLgpd': acceptLgpd,
    };
  }
}