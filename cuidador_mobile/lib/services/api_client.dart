class ApiClient {
  // Endereço da API
  static const String baseUrl = 'https://cuidador-e5ckajenduhyfwa2.brazilsouth-01.azurewebsites.net';

  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get registerUrl => '$baseUrl/api/auth/register';
  static String get painAssessmentUrl => '$baseUrl/api/PainAssessments';

  static const String painEvolutionUrl = "$baseUrl/api/reports/pain";
  static const String feedbackUrl = "$baseUrl/api/Feedback";
}