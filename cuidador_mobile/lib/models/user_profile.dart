class AccessibilityPreference {
  final double fontScale;
  final bool highContrast;
  final bool voiceReading;

  AccessibilityPreference({
    required this.fontScale,
    required this.highContrast,
    required this.voiceReading,
  });

  factory AccessibilityPreference.fromJson(Map<String, dynamic> json) {
    return AccessibilityPreference(
      fontScale: (json['fontScale'] ?? 1.0).toDouble(),
      highContrast: (json['highContrast'] ?? false) as bool,
      voiceReading: (json['voiceReading'] ?? false) as bool,
    );
  }
}

class ConsentLgpd {
  final bool accepted;
  final DateTime? acceptedAt;
  final String? policyVersion;

  ConsentLgpd({
    required this.accepted,
    this.acceptedAt,
    this.policyVersion,
  });

  factory ConsentLgpd.fromJson(Map<String, dynamic> json) {
    return ConsentLgpd(
      accepted: (json['accepted'] ?? false) as bool,
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      policyVersion: json['policyVersion'] as String?,
    );
  }
}

class UserProfile {
  final int id;
  final String fullName;
  final int? age;
  final String? sex;
  final String? phoneNumber;
  final String email;
  final List<String> comorbidities;
  final AccessibilityPreference? accessibility;
  final ConsentLgpd? consent;

  UserProfile({
    required this.id,
    required this.fullName,
    this.age,
    this.sex,
    this.phoneNumber,
    required this.email,
    required this.comorbidities,
    this.accessibility,
    this.consent,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      age: json['age'] as int?,
      sex: json['sex'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String,
      comorbidities: (json['comorbidities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      accessibility: json['accessibility'] != null
          ? AccessibilityPreference.fromJson(
              json['accessibility'] as Map<String, dynamic>,
            )
          : null,
      consent: json['consent'] != null
          ? ConsentLgpd.fromJson(json['consent'] as Map<String, dynamic>)
          : null,
    );
  }
}