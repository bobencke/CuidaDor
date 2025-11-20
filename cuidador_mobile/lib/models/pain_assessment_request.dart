class PainAssessmentRequest {
  final int usualPain;
  final int localizedPain;
  final int moodToday;
  final int sleepQuality;
  final bool limitsPhysicalActivities;
  final bool painWorseWithMovement;
  final bool usesPainMedication;
  final bool usesNonDrugPainRelief;
  final String? notes;

  PainAssessmentRequest({
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

  Map<String, dynamic> toJson() {
    return {
      'usualPain': usualPain,
      'localizedPain': localizedPain,
      'moodToday': moodToday,
      'sleepQuality': sleepQuality,
      'limitsPhysicalActivities': limitsPhysicalActivities,
      'painWorseWithMovement': painWorseWithMovement,
      'usesPainMedication': usesPainMedication,
      'usesNonDrugPainRelief': usesNonDrugPainRelief,
      'notes': notes,
    };
  }
}