class PainEvolutionPoint {
  final DateTime date;
  final double averagePain;

  PainEvolutionPoint({
    required this.date,
    required this.averagePain,
  });

  factory PainEvolutionPoint.fromJson(Map<String, dynamic> json) {
    return PainEvolutionPoint(
      date: DateTime.parse(json['date'] as String),
      averagePain: (json['averagePain'] as num).toDouble(),
    );
  }
}

class PainReport {
  final List<PainEvolutionPoint> points;
  final double? reductionPercent;

  PainReport({
    required this.points,
    this.reductionPercent,
  });

  factory PainReport.fromJson(Map<String, dynamic> json) {
    final list = json['points'] as List<dynamic>? ?? [];

    return PainReport(
      points: list
          .map((e) => PainEvolutionPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      reductionPercent: (json['reductionPercent'] as num?)?.toDouble(),
    );
  }
}

class GeneralFeedbackRequest {
  final int overallFeeling;
  final int bodyFeeling;
  final String? comment;

  GeneralFeedbackRequest({
    required this.overallFeeling,
    required this.bodyFeeling,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'overallFeeling': overallFeeling,
        'bodyFeeling': bodyFeeling,
        'comment': comment,
      };
}