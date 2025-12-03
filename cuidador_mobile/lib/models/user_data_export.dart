import 'user_profile.dart';

T _val<T>(Map<String, dynamic> json, String pascal) {
  final camel = pascal[0].toLowerCase() + pascal.substring(1);
  final v = json[camel] ?? json[pascal];
  if (v is T) return v;
  throw Exception('Campo $pascal/$camel ausente ou inválido no JSON');
}

T? _valOpt<T>(Map<String, dynamic> json, String pascal) {
  final camel = pascal[0].toLowerCase() + pascal.substring(1);
  final v = json[camel] ?? json[pascal];
  if (v == null) return null;
  if (v is T) return v;
  throw Exception('Campo opcional $pascal/$camel inválido no JSON');
}

/// Comorbidade
class UserComorbidityExport {
  final int id;
  final int userId;
  final String name;

  UserComorbidityExport({
    required this.id,
    required this.userId,
    required this.name,
  });

  factory UserComorbidityExport.fromJson(Map<String, dynamic> json) {
    return UserComorbidityExport(
      id: _val<int>(json, 'Id'),
      userId: _val<int>(json, 'UserId'),
      name: _val<String>(json, 'Name'),
    );
  }
}

/// Avaliação de dor diária
class PainAssessmentExport {
  final int id;
  final int userId;
  final DateTime date;

  final int usualPain;        // enum PainScale (0–5)
  final int localizedPain;    // enum FaceScale
  final int moodToday;        // enum FaceScale
  final int sleepQuality;     // enum FaceScale

  final bool limitsPhysicalActivities;
  final bool painWorseWithMovement;
  final bool usesPainMedication;
  final bool usesNonDrugPainRelief;

  final String? notes;

  PainAssessmentExport({
    required this.id,
    required this.userId,
    required this.date,
    required this.usualPain,
    required this.localizedPain,
    required this.moodToday,
    required this.sleepQuality,
    required this.limitsPhysicalActivities,
    required this.painWorseWithMovement,
    required this.usesPainMedication,
    required this.usesNonDrugPainRelief,
    this.notes,
  });

  factory PainAssessmentExport.fromJson(Map<String, dynamic> json) {
    return PainAssessmentExport(
      id: _val<int>(json, 'Id'),
      userId: _val<int>(json, 'UserId'),
      date: DateTime.parse(_val<String>(json, 'Date')),
      usualPain: _val<int>(json, 'UsualPain'),
      localizedPain: _val<int>(json, 'LocalizedPain'),
      moodToday: _val<int>(json, 'MoodToday'),
      sleepQuality: _val<int>(json, 'SleepQuality'),
      limitsPhysicalActivities:
          _val<bool>(json, 'LimitsPhysicalActivities'),
      painWorseWithMovement: _val<bool>(json, 'PainWorseWithMovement'),
      usesPainMedication: _val<bool>(json, 'UsesPainMedication'),
      usesNonDrugPainRelief: _val<bool>(json, 'UsesNonDrugPainRelief'),
      notes: _valOpt<String>(json, 'Notes'),
    );
  }
}

/// Sessão de técnica de alívio
class TechniqueSessionExport {
  final int id;
  final int userId;
  final int reliefTechniqueId;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int resultFeeling; // enum FaceScaleAfterPractice
  final String? notes;

  TechniqueSessionExport({
    required this.id,
    required this.userId,
    required this.reliefTechniqueId,
    required this.startedAt,
    required this.finishedAt,
    required this.resultFeeling,
    this.notes,
  });

  factory TechniqueSessionExport.fromJson(Map<String, dynamic> json) {
    return TechniqueSessionExport(
      id: _val<int>(json, 'Id'),
      userId: _val<int>(json, 'UserId'),
      reliefTechniqueId: _val<int>(json, 'ReliefTechniqueId'),
      startedAt: DateTime.parse(_val<String>(json, 'StartedAt')),
      finishedAt: DateTime.parse(_val<String>(json, 'FinishedAt')),
      resultFeeling: _val<int>(json, 'ResultFeeling'),
      notes: _valOpt<String>(json, 'Notes'),
    );
  }
}

/// Feedback geral
class GeneralFeedbackExport {
  final int id;
  final int userId;
  final DateTime createdAt;
  final int? generalFeeling;
  final String? text;

  GeneralFeedbackExport({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.generalFeeling,
    this.text,
  });

  factory GeneralFeedbackExport.fromJson(Map<String, dynamic> json) {
    return GeneralFeedbackExport(
      id: _val<int>(json, 'Id'),
      userId: _val<int>(json, 'UserId'),
      createdAt: DateTime.parse(_val<String>(json, 'CreatedAt')),
      generalFeeling: _valOpt<int>(json, 'GeneralFeeling'),
      text: _valOpt<String>(json, 'Text'),
    );
  }
}

/// Técnica de alívio (tabela de referência)
class ReliefTechniqueExport {
  final int id;
  final String name;
  final String? shortDescription;
  final String? warningText;

  ReliefTechniqueExport({
    required this.id,
    required this.name,
    this.shortDescription,
    this.warningText,
  });

  factory ReliefTechniqueExport.fromJson(Map<String, dynamic> json) {
    return ReliefTechniqueExport(
      id: _val<int>(json, 'Id'),
      name: _val<String>(json, 'Name'),
      shortDescription: _valOpt<String>(json, 'ShortDescription'),
      warningText: _valOpt<String>(json, 'WarningText'),
    );
  }
}

/// Passo de técnica
class TechniqueStepExport {
  final int id;
  final int reliefTechniqueId;
  final int order;
  final String description;

  TechniqueStepExport({
    required this.id,
    required this.reliefTechniqueId,
    required this.order,
    required this.description,
  });

  factory TechniqueStepExport.fromJson(Map<String, dynamic> json) {
    return TechniqueStepExport(
      id: _val<int>(json, 'Id'),
      reliefTechniqueId: _val<int>(json, 'ReliefTechniqueId'),
      order: _val<int>(json, 'Order'),
      description: _val<String>(json, 'Description'),
    );
  }
}

class UserDataExport {
  final UserProfile user;
  final List<UserComorbidityExport> comorbidities;
  final List<PainAssessmentExport> painAssessments;
  final List<TechniqueSessionExport> techniqueSessions;
  final List<GeneralFeedbackExport> generalFeedbacks;
  final List<ReliefTechniqueExport> reliefTechniques;
  final List<TechniqueStepExport> techniqueSteps;

  UserDataExport({
    required this.user,
    required this.comorbidities,
    required this.painAssessments,
    required this.techniqueSessions,
    required this.generalFeedbacks,
    required this.reliefTechniques,
    required this.techniqueSteps,
  });

  factory UserDataExport.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] ?? json['User']) as Map<String, dynamic>;

    List<Map<String, dynamic>> _list(String pascal) {
      final camel = pascal[0].toLowerCase() + pascal.substring(1);
      final raw = json[camel] ?? json[pascal] ?? [];
      return (raw as List).cast<Map<String, dynamic>>();
    }

    return UserDataExport(
      user: UserProfile.fromJson(userJson),
      comorbidities: _list('Comorbidities')
          .map(UserComorbidityExport.fromJson)
          .toList(),
      painAssessments: _list('PainAssessments')
          .map(PainAssessmentExport.fromJson)
          .toList(),
      techniqueSessions: _list('TechniqueSessions')
          .map(TechniqueSessionExport.fromJson)
          .toList(),
      generalFeedbacks: _list('GeneralFeedbacks')
          .map(GeneralFeedbackExport.fromJson)
          .toList(),
      reliefTechniques: _list('ReliefTechniques')
          .map(ReliefTechniqueExport.fromJson)
          .toList(),
      techniqueSteps: _list('TechniqueSteps')
          .map(TechniqueStepExport.fromJson)
          .toList(),
    );
  }
}