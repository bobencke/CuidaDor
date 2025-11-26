/// Helpers para lidar com JSON vindo do .NET (camelCase ou PascalCase)
T _val<T>(Map<String, dynamic> json, String camel, String pascal) {
  final v = json[camel] ?? json[pascal];
  if (v is T) return v;
  throw Exception('Campo $camel/$pascal ausente ou inválido no JSON');
}

T? _valOpt<T>(Map<String, dynamic> json, String camel, String pascal) {
  final v = json[camel] ?? json[pascal];
  if (v == null) return null;
  if (v is T) return v;
  throw Exception('Campo opcional $camel/$pascal inválido no JSON');
}

/// Item da lista de técnicas de alívio
class ReliefTechniqueListItem {
  final int id;
  final String name;
  final String shortDescription;
  final String? warningText;

  ReliefTechniqueListItem({
    required this.id,
    required this.name,
    required this.shortDescription,
    this.warningText,
  });

  factory ReliefTechniqueListItem.fromJson(Map<String, dynamic> json) {
    return ReliefTechniqueListItem(
      id: _val<int>(json, 'id', 'Id'),
      name: _val<String>(json, 'name', 'Name'),
      shortDescription:
          _val<String>(json, 'shortDescription', 'ShortDescription'),
      warningText: _valOpt<String>(json, 'warningText', 'WarningText'),
    );
  }
}

/// Passo a passo de uma técnica
class TechniqueStep {
  final int order;
  final String description;

  TechniqueStep({
    required this.order,
    required this.description,
  });

  factory TechniqueStep.fromJson(Map<String, dynamic> json) {
    return TechniqueStep(
      order: _val<int>(json, 'order', 'Order'),
      description: _val<String>(json, 'description', 'Description'),
    );
  }
}

/// Detalhe de técnica (herda os campos do item da lista)
class ReliefTechniqueDetail extends ReliefTechniqueListItem {
  final List<TechniqueStep> steps;

  ReliefTechniqueDetail({
    required int id,
    required String name,
    required String shortDescription,
    String? warningText,
    required this.steps,
  }) : super(
          id: id,
          name: name,
          shortDescription: shortDescription,
          warningText: warningText,
        );

  factory ReliefTechniqueDetail.fromJson(Map<String, dynamic> json) {
    final stepsJson = (json['steps'] ??
            json['Steps'] ??
            <dynamic>[]) as List<dynamic>;

    return ReliefTechniqueDetail(
      id: _val<int>(json, 'id', 'Id'),
      name: _val<String>(json, 'name', 'Name'),
      shortDescription:
          _val<String>(json, 'shortDescription', 'ShortDescription'),
      warningText: _valOpt<String>(json, 'warningText', 'WarningText'),
      steps: stepsJson
          .map((e) => TechniqueStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}