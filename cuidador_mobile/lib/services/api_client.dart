class ApiClient {
  static const String baseUrl = 'https://cuidador-e5ckajenduhyfwa2.brazilsouth-01.azurewebsites.net';

  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get registerUrl => '$baseUrl/api/auth/register';

  static String get painAssessmentUrl => '$baseUrl/api/PainAssessments';

  static String get reliefTechniquesUrl => '$baseUrl/api/ReliefTechniques';
  static String reliefTechniqueDetailUrl(int id) =>
      '$baseUrl/api/ReliefTechniques/$id';
  static String get reliefTechniqueSessionUrl =>
      '$baseUrl/api/ReliefTechniques/sessions';

  static String get painReportUrl => '$baseUrl/api/Reports/pain';

  static String get feedbackUrl => '$baseUrl/api/Feedback';
}
