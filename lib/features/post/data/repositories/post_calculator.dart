// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:math' as math;
import 'package:saprbar_desktop/core/models/project_model.dart';
import 'package:saprbar_desktop/features/post/data/models/diagram_model.dart';
import 'package:saprbar_desktop/features/post/domain/entities/stress_analysis.dart';
import 'package:saprbar_desktop/features/pro/data/models/calculation_result_model.dart';

/// Калькулятор для постпроцессора
/// Вычисляет эпюры и анализирует результаты
class PostCalculator {
  final ProjectModel project; // 🔴 ИСПРАВЛЕНО: Теперь не nullable
  final CalculationResultModel calculationResult;

  PostCalculator({
    required this.project,
    required this.calculationResult,
  });

  /// ОСНОВНОЙ МЕТОД: Построить все эпюры
  AllDiagrams buildAllDiagrams() {
    if (!calculationResult.isSuccessful) {
      throw Exception('Расчёт не был выполнен успешно');
    }

    final nodeResultsMap = <int, dynamic>{};
    final elemResultsMap = <int, dynamic>{};

    // Создать карты для удобства
    for (var nodeResult in calculationResult.nodeResults) {
      nodeResultsMap[nodeResult.nodeId] = nodeResult;
    }

    for (var elemResult in calculationResult.elementResults) {
      elemResultsMap[elemResult.elementId] = elemResult;
    }

    // Построить каждую эпюру
    final internalForces =
        _buildInternalForceDiagram(nodeResultsMap, elemResultsMap);
    final stresses = _buildStressDiagram(elemResultsMap);
    final displacements = _buildDisplacementDiagram(nodeResultsMap);
    final strains = _buildStrainDiagram(elemResultsMap);

    return AllDiagrams(
      internalForces: internalForces,
      stresses: stresses,
      displacements: displacements,
      strains: strains,
    );
  }

  /// Построить эпюру внутренних сил Nx
  DiagramModel _buildInternalForceDiagram(
    Map<int, dynamic> nodeResults,
    Map<int, dynamic> elemResults,
  ) {
    final points = <DiagramPoint>[];
    final values = <double>[];

    // Для каждого стержня
    for (var element in project.elements) {
      final elemResult = elemResults[element.id];
      if (elemResult == null) continue;

      // Получить узлы стержня
      final nodeStart =
          project.nodes.firstWhere((n) => n.id == element.nodeStartId);
      final nodeEnd =
          project.nodes.firstWhere((n) => n.id == element.nodeEndId);

      // Добавить две точки для эпюры (начало и конец стержня)
      points.add(DiagramPoint(
        x: nodeStart.x.toDouble(),
        value: elemResult.internalForce,
        elementId: element.id,
      ));

      points.add(DiagramPoint(
        x: nodeEnd.x.toDouble(),
        value: elemResult.internalForce,
        elementId: element.id,
      ));

      values.add(elemResult.internalForce);
    }

    // Отсортировать по x
    points.sort((a, b) => a.x.compareTo(b.x));

    final maxValue = values.isEmpty ? 0.0 : values.reduce(math.max);
    final minValue = values.isEmpty ? 0.0 : values.reduce(math.min);
    final averageValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a + b) / values.length;

    return DiagramModel(
      name: 'Nx',
      unit: 'Н',
      points: points,
      maxValue: maxValue,
      minValue: minValue,
      averageValue: averageValue,
    );
  }

  /// Построить эпюру напряжений σx
  DiagramModel _buildStressDiagram(
    Map<int, dynamic> elemResults,
  ) {
    final points = <DiagramPoint>[];
    final values = <double>[];

    for (var element in project.elements) {
      final elemResult = elemResults[element.id];
      if (elemResult == null) continue;

      final nodeStart =
          project.nodes.firstWhere((n) => n.id == element.nodeStartId);
      final nodeEnd =
          project.nodes.firstWhere((n) => n.id == element.nodeEndId);

      points.add(DiagramPoint(
        x: nodeStart.x.toDouble(),
        value: elemResult.stress,
        elementId: element.id,
      ));

      points.add(DiagramPoint(
        x: nodeEnd.x.toDouble(),
        value: elemResult.stress,
        elementId: element.id,
      ));

      values.add(elemResult.stress);
    }

    points.sort((a, b) => a.x.compareTo(b.x));

    final maxValue = values.isEmpty ? 0.0 : values.reduce(math.max);
    final minValue = values.isEmpty ? 0.0 : values.reduce(math.min);
    final averageValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a + b) / values.length;

    return DiagramModel(
      name: 'σx',
      unit: 'МПа',
      points: points,
      maxValue: maxValue,
      minValue: minValue,
      averageValue: averageValue,
    );
  }

  /// Построить эпюру перемещений Δ
  DiagramModel _buildDisplacementDiagram(
    Map<int, dynamic> nodeResults,
  ) {
    final points = <DiagramPoint>[];
    final values = <double>[];

    // Для каждого узла
    for (var node in project.nodes) {
      final nodeResult = nodeResults[node.id];
      if (nodeResult == null) continue;

      // Найти стержень, который содержит этот узел
      final element = project.elements.firstWhere(
        (e) => e.nodeEndId == node.id || e.nodeStartId == node.id,
        orElse: () => project.elements.first,
      );

      points.add(DiagramPoint(
        x: node.x.toDouble(),
        value: nodeResult.displacement,
        elementId: element.id,
      ));

      values.add(nodeResult.displacement);
    }

    points.sort((a, b) => a.x.compareTo(b.x));

    final maxValue = values.isEmpty ? 0.0 : values.reduce(math.max);
    final minValue = values.isEmpty ? 0.0 : values.reduce(math.min);
    final averageValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a + b) / values.length;

    return DiagramModel(
      name: 'Δ',
      unit: 'м',
      points: points,
      maxValue: maxValue,
      minValue: minValue,
      averageValue: averageValue,
    );
  }

  /// Построить эпюру деформаций ε
  DiagramModel _buildStrainDiagram(
    Map<int, dynamic> elemResults,
  ) {
    final points = <DiagramPoint>[];
    final values = <double>[];

    for (var element in project.elements) {
      final elemResult = elemResults[element.id];
      if (elemResult == null) continue;

      final nodeStart =
          project.nodes.firstWhere((n) => n.id == element.nodeStartId);
      final nodeEnd =
          project.nodes.firstWhere((n) => n.id == element.nodeEndId);

      points.add(DiagramPoint(
        x: nodeStart.x.toDouble(),
        value: elemResult.strain,
        elementId: element.id,
      ));

      points.add(DiagramPoint(
        x: nodeEnd.x.toDouble(),
        value: elemResult.strain,
        elementId: element.id,
      ));

      values.add(elemResult.strain);
    }

    points.sort((a, b) => a.x.compareTo(b.x));

    final maxValue = values.isEmpty ? 0.0 : values.reduce(math.max);
    final minValue = values.isEmpty ? 0.0 : values.reduce(math.min);
    final averageValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a + b) / values.length;

    return DiagramModel(
      name: 'ε',
      unit: 'безразм',
      points: points,
      maxValue: maxValue,
      minValue: minValue,
      averageValue: averageValue,
    );
  }

  /// Анализ прочности: проверка |σ| ≤ [σ]допустимое
  List<ElementStressAnalysis> analyzeStress() {
    if (!calculationResult.isSuccessful) {
      throw Exception('Расчёт не был выполнен успешно');
    }

    final analysis = <ElementStressAnalysis>[];

    for (var elemResult in calculationResult.elementResults) {
      // 🔴 ИСПРАВЛЕНО: Получаем element из проекта для допустимого напряжения
      final element = project.elements
          .firstWhere((e) => e.id == elemResult.elementId);
      
      final actualStress = elemResult.stress.abs();
      final allowableStress = element.allowableStress ?? 250.0; // МПа

      final isPassed = actualStress <= allowableStress;

      final safetyFactor =
          actualStress > 0 ? allowableStress / actualStress : double.infinity;

      String status;
      if (safetyFactor > 2.0) {
        status = 'OK';
      } else if (safetyFactor > 1.0) {
        status = 'WARNING';
      } else {
        status = 'DANGER';
      }

      analysis.add(ElementStressAnalysis(
        elementId: elemResult.elementId,
        stress: actualStress,
        allowableStress: allowableStress,
        isPassed: isPassed,
        safetyFactor: safetyFactor,
        status: status,
      ));
    }

    return analysis;
  }
}

/// Контейнер для всех эпюр
class AllDiagrams {
  final DiagramModel internalForces; // Nx
  final DiagramModel stresses; // σx
  final DiagramModel displacements; // Δ
  final DiagramModel strains; // ε

  AllDiagrams({
    required this.internalForces,
    required this.stresses,
    required this.displacements,
    required this.strains,
  });
}
