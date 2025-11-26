class TechniqueSessionRequest {
  final int reliefTechniqueId;
  final DateTime startedAt;
  final DateTime finishedAt;
  /// 1 = Melhor, 2 = Igual, 3 = Pior (FaceScaleAfterPractice)
  final int resultFeeling;
  final String? notes;

  TechniqueSessionRequest({
    required this.reliefTechniqueId,
    required this.startedAt,
    required this.finishedAt,
    required this.resultFeeling,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'reliefTechniqueId': reliefTechniqueId,
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt.toIso8601String(),
      'resultFeeling': resultFeeling,
      'notes': notes,
    };
  }
}