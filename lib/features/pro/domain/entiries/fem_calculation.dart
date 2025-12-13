// lib/features/processor/domain/entities/fem_calculation.dart

import 'package:equatable/equatable.dart';

/// Матрица жёсткости и другие расчётные сущности
class FemCalculationData extends Equatable {
  final List<List<double>> globalStiffnessMatrix;
  final List<double> loadVector;
  final List<double> displacementVector;
  final List<int> fixedNodes; // Зафиксированные узлы
  final int totalDOF; // Общее число степеней свободы

  const FemCalculationData({
    required this.globalStiffnessMatrix,
    required this.loadVector,
    required this.displacementVector,
    required this.fixedNodes,
    required this.totalDOF,
  });

  @override
  List<Object?> get props => [
    globalStiffnessMatrix,
    loadVector,
    displacementVector,
    fixedNodes,
    totalDOF,
  ];
}
