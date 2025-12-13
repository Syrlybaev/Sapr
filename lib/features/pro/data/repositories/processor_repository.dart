// lib/features/processor/data/repositories/processor_repository_impl.dart

import 'package:saprbar_desktop/core/models/project_model.dart';
import 'package:saprbar_desktop/features/pro/data/data_source/fem_calculator.dart';
import 'package:saprbar_desktop/features/pro/data/models/calculation_result_model.dart';

/// Имплементация репозитория процессора
class ProcessorRepository {
  Future<CalculationResultModel> calculateStructure(
    ProjectModel project,
  ) async {
    try {
      // Создать калькулятор
      final calculator = FemCalculator(
        nodes: project.nodes,
        elements: project.elements,
        fixLeft: project.fixLeft,
        fixRight: project.fixRight,
      );

      // Выполнить расчёт
      final calcResult = calculator.calculate();

      if (!calcResult['success']) {
        return CalculationResultModel(
          projectName: project.name,
          nodeResults: [],
          elementResults: [],
          isSuccessful: false,
          errorMessage: calcResult['error'] as String,
          calculatedAt: DateTime.now(),
        );
      }

      // Преобразовать результаты
      final displacements = calcResult['displacements'] as List<double>;
      final elementResults =
          calcResult['elementResults'] as Map<int, Map<String, double>>;

      // Создать результаты для узлов
      final nodeResults = <NodeCalculationResult>[];
      for (int i = 0; i < project.nodes.length; i++) {
        nodeResults.add(
          NodeCalculationResult(
            nodeId: project.nodes[i].id,
            displacement: displacements[i],
            loadX: project.nodes[i].loadX,
          ),
        );
      }

      // Создать результаты для стержней
      final elemResults = <ElementCalculationResult>[];
      for (var elemEntry in elementResults.entries) {
        elemResults.add(
          ElementCalculationResult(
            elementId: elemEntry.key,
            internalForce: elemEntry.value['internalForce'] ?? 0.0,
            stress: elemEntry.value['stress'] ?? 0.0,
            strain: elemEntry.value['strain'] ?? 0.0,
          ),
        );
      }
      return CalculationResultModel(
        projectName: project.name,
        nodeResults: nodeResults,
        elementResults: elemResults,
        isSuccessful: true,
        calculatedAt: DateTime.now(),
      );
    } catch (e) {
      throw (e.toString());
    }
  }
}
