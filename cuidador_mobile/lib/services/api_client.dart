class ApiClient {
  // Endereço API
  static const String baseUrl = 'https://cuidador-e5ckajenduhyfwa2.brazilsouth-01.azurewebsites.net';

  // Autenticação/registro
  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get registerUrl => '$baseUrl/api/auth/register';

  // Avaliação da dor
  static String get painAssessmentUrl => '$baseUrl/api/PainAssessments';

  // Técnicas de alívio
  static String get reliefTechniquesUrl => '$baseUrl/api/ReliefTechniques';
  static String reliefTechniqueDetailUrl(int id) =>
      '$baseUrl/api/ReliefTechniques/$id';
  static String get reliefTechniqueSessionUrl =>
      '$baseUrl/api/ReliefTechniques/sessions';

  // Relatórios de dor
  static String get painReportUrl => '$baseUrl/api/Reports/pain';

  // Feedback geral
  static String get feedbackUrl => '$baseUrl/api/Feedback';

  // Perfil do usuário logado
  static String get userMeUrl => '$baseUrl/api/Users/me';
}