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
  final List<PainEvolutionPoint> evolution;
  final double? percentageReduction;

  PainReport({
    required this.evolution,
    required this.percentageReduction,
  });

  factory PainReport.fromJson(Map<String, dynamic> json) {
    final list = json['evolution'] as List<dynamic>? ?? [];
    return PainReport(
      evolution: list
          .map((e) => PainEvolutionPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      percentageReduction: json['percentageReduction'] == null
          ? null
          : (json['percentageReduction'] as num).toDouble(),
    );
  }
}