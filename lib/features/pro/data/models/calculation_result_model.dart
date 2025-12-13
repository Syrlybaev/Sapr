// lib/features/processor/data/models/calculation_result_model.dart

import 'package:equatable/equatable.dart';

/// Результат расчёта одного стержня
class ElementCalculationResult extends Equatable {
  final int elementId;
  final double internalForce; // Продольная сила Nx [Н]
  final double stress; // Нормальное напряжение σx [МПа]
  final double strain; // Деформация ε [безразм]

  const ElementCalculationResult({
    required this.elementId,
    required this.internalForce,
    required this.stress,
    required this.strain,
  });

  @override
  List<Object?> get props => [elementId, internalForce, stress, strain];
}

/// Результат расчёта для узла
class NodeCalculationResult extends Equatable {
  final int nodeId;
  final double displacement; // Перемещение узла [м]
  final double loadX; // Сосредоточенная нагрузка [Н]

  const NodeCalculationResult({
    required this.nodeId,
    required this.displacement,
    required this.loadX,
  });

  @override
  List<Object?> get props => [nodeId, displacement, loadX];
}

/// Полный результат расчёта всей конструкции
class CalculationResultModel extends Equatable {
  final String projectName;
  final List<NodeCalculationResult> nodeResults;
  final List<ElementCalculationResult> elementResults;
  final bool isSuccessful;
  final String? errorMessage;
  final DateTime calculatedAt;

  const CalculationResultModel({
    required this.projectName,
    required this.nodeResults,
    required this.elementResults,
    required this.isSuccessful,
    this.errorMessage,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [
    projectName,
    nodeResults,
    elementResults,
    isSuccessful,
    errorMessage,
    calculatedAt,
  ];

  factory CalculationResultModel.fromJson(Map<String, dynamic> json) {
    return CalculationResultModel(
      projectName: json['projectName'] as String,
      nodeResults: (json['nodeResults'] as List)
          .map((e) => NodeCalculationResult(
            nodeId: e['nodeId'] as int,
            displacement: (e['displacement'] as num).toDouble(),
            loadX: (e['loadX'] as num).toDouble(),
          ))
          .toList(),
      elementResults: (json['elementResults'] as List)
          .map((e) => ElementCalculationResult(
            elementId: e['elementId'] as int,
            internalForce: (e['internalForce'] as num).toDouble(),
            stress: (e['stress'] as num).toDouble(),
            strain: (e['strain'] as num).toDouble(),  
          ))
          .toList(),
      isSuccessful: json['isSuccessful'] as bool,
      errorMessage: json['errorMessage'] as String?,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'projectName': projectName,
    'nodeResults': nodeResults
        .map((e) => {
          'nodeId': e.nodeId,
          'displacement': e.displacement,
          'loadX': e.loadX,
        })
        .toList(),
    'elementResults': elementResults
        .map((e) => {
          'elementId': e.elementId,
          'internalForce': e.internalForce,
          'stress': e.stress,
          'strain': e.strain, 
        })
        .toList(),
    'isSuccessful': isSuccessful,
    'errorMessage': errorMessage,
    'calculatedAt': calculatedAt.toIso8601String(),
  };

}
