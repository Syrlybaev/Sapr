import 'dart:math' as math;

import 'package:saprbar_desktop/core/models/project_model.dart';
import 'package:saprbar_desktop/features/post/data/models/diagram_model.dart';
import 'package:saprbar_desktop/features/post/domain/entities/stress_analysis.dart';
import 'package:saprbar_desktop/features/pro/data/models/calculation_result_model.dart';

/// ✅✅✅ ФИНАЛЬНЫЙ ИСПРАВЛЕННЫЙ ПОСТПРОЦЕССОР
///
/// КЛЮЧЕВАЯ ФОРМУЛА ДЛЯ Nx(x):
/// Nx(x) = Nx(0) - qx * x
///
/// Где:
/// Nx(0) = Nx_avg + qx * L / 2 ← РЕАКЦИЯ ОПОРЫ
/// Nx_avg = (E*A/L) * (u_end - u_start) ← СРЕДНЕЕ ИЗ МКЭ
///
/// Эта формула работает для всех 5 примеров задач!

class PostCalculator {
  final ProjectModel project;
  final CalculationResultModel calculationResult;

  PostCalculator({
    required this.project,
    required this.calculationResult,
  });

  AllDiagrams buildAllDiagrams() {
    if (!calculationResult.isSuccessful) {
      throw Exception('Расчёт не был выполнен успешно');
    }

    final internalForces = _buildInternalForceDiagram();
    final stresses = _buildStressDiagram();
    final displacements = _buildDisplacementDiagram();
    final strains = _buildStrainDiagram();

    return AllDiagrams(
      internalForces: internalForces,
      stresses: stresses,
      displacements: displacements,
      strains: strains,
    );
  }

  /// ✅ ЭПЮРА Nx(x) — ОКОНЧАТЕЛЬНАЯ ИСПРАВЛЕННАЯ ФОРМУЛА
  DiagramModel _buildInternalForceDiagram() {
    final points = <DiagramPoint>[];
    final values = <double>[];

    for (var element in project.elements) {
      final nodeStart = project.nodes.firstWhere(
        (n) => n.id == element.nodeStartId,
      );
      final nodeEnd = project.nodes.firstWhere(
        (n) => n.id == element.nodeEndId,
      );

      final nodeStartResult = calculationResult.nodeResults
          .firstWhere((n) => n.nodeId == nodeStart.id);
      final nodeEndResult = calculationResult.nodeResults
          .firstWhere((n) => n.nodeId == nodeEnd.id);

      final uStart = nodeStartResult.displacement;
      final uEnd = nodeEndResult.displacement;
      final E = element.E;
      final A = element.A;
      final L = (nodeEnd.x - nodeStart.x).abs();
      final qx = element.qx;

      /// ✅ КЛЮЧЕВЫЕ СТРОКИ - ИСПРАВЛЕННАЯ ФОРМУЛА
      final Nx_avg = (E * A / L) * (uEnd - uStart);
      final NxAtStart = Nx_avg + qx * L / 2; // ← РЕАКЦИЯ ОПОРЫ!

      final xStart = nodeStart.x;
      const int subdivisions = 30;

      for (int i = 0; i <= subdivisions; i++) {
        final ratio = i / subdivisions;
        final localCoord = ratio * L;
        final globalX = xStart + localCoord;

        /// ✅ ФОРМУЛА: Nx(x) = Nx(0) - qx * x
        final NxValue = NxAtStart - qx * localCoord;

        points.add(DiagramPoint(
          x: globalX,
          value: NxValue,
          elementId: element.id,
          isNode: (i == 0 || i == subdivisions),
        ));

        values.add(NxValue);
      }
    }

    if (points.isEmpty) {
      return DiagramModel(
        name: 'Nx',
        unit: 'Н',
        points: [],
        maxValue: 0.0,
        minValue: 0.0,
        averageValue: 0.0,
      );
    }

    points.sort((a, b) => a.x.compareTo(b.x));
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
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

  /// ✅ ЭПЮРА σx(x) = Nx(x) / A
  DiagramModel _buildStressDiagram() {
    final points = <DiagramPoint>[];
    final values = <double>[];

    for (var element in project.elements) {
      final nodeStart = project.nodes.firstWhere(
        (n) => n.id == element.nodeStartId,
      );
      final nodeEnd = project.nodes.firstWhere(
        (n) => n.id == element.nodeEndId,
      );

      final nodeStartResult = calculationResult.nodeResults
          .firstWhere((n) => n.nodeId == nodeStart.id);
      final nodeEndResult = calculationResult.nodeResults
          .firstWhere((n) => n.nodeId == nodeEnd.id);

      final uStart = nodeStartResult.displacement;
      final uEnd = nodeEndResult.displacement;
      final E = element.E;
      final A = element.A;
      final L = (nodeEnd.x - nodeStart.x).abs();
      final qx = element.qx;

      /// ✅ ТА ЖЕ ИСПРАВЛЕННАЯ ФОРМУЛА
      final Nx_avg = (E * A / L) * (uEnd - uStart);
      final NxAtStart = Nx_avg + qx * L / 2;

      final xStart = nodeStart.x;
      const int subdivisions = 30;

      for (int i = 0; i <= subdivisions; i++) {
        final ratio = i / subdivisions;
        final localCoord = ratio * L;
        final globalX = xStart + localCoord;

        final NxValue = NxAtStart - qx * localCoord;
        final sigma = A > 0 ? NxValue / A : 0.0;

        points.add(DiagramPoint(
          x: globalX,
          value: sigma,
          elementId: element.id,
          isNode: (i == 0 || i == subdivisions),
        ));

        values.add(sigma);
      }
    }

    if (points.isEmpty) {
      return DiagramModel(
        name: 'σx',
        unit: 'МПа',
        points: [],
        maxValue: 0.0,
        minValue: 0.0,
        averageValue: 0.0,
      );
    }

    points.sort((a, b) => a.x.compareTo(b.x));
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
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

  /// ✅ ЭПЮРА ПЕРЕМЕЩЕНИЙ (от МКЭ результатов)
  DiagramModel _buildDisplacementDiagram() {
    final points = <DiagramPoint>[];
    final values = <double>[];

    for (var node in project.nodes) {
      final nodeResult = calculationResult.nodeResults
          .firstWhere((n) => n.nodeId == node.id);

      points.add(DiagramPoint(
        x: node.x,
        value: nodeResult.displacement,
        elementId: 0,
        isNode: true,
      ));

      values.add(nodeResult.displacement);
    }

    for (int i = 0; i < project.nodes.length - 1; i++) {
      final node1 = project.nodes[i];
      final node2 = project.nodes[i + 1];

      final result1 = calculationResult.nodeResults
          .firstWhere((n) => n.nodeId == node1.id);
      final result2 = calculationResult.nodeResults
          .firstWhere((n) => n.nodeId == node2.id);

      const int subdivisions = 15;

      for (int j = 1; j < subdivisions; j++) {
        final ratio = j / subdivisions;
        final x = node1.x + (node2.x - node1.x) * ratio;
        final u = result1.displacement +
            (result2.displacement - result1.displacement) * ratio;

        points.add(DiagramPoint(
          x: x,
          value: u,
          elementId: 0,
          isNode: false,
        ));

        values.add(u);
      }
    }

    if (points.isEmpty) {
      return DiagramModel(
        name: 'Δ',
        unit: 'м',
        points: [],
        maxValue: 0.0,
        minValue: 0.0,
        averageValue: 0.0,
      );
    }

    points.sort((a, b) => a.x.compareTo(b.x));
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
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

  /// ✅ ЭПЮРА ДЕФОРМАЦИЙ ε = σ / E
  DiagramModel _buildStrainDiagram() {
    final points = <DiagramPoint>[];
    final values = <double>[];

    for (var element in project.elements) {
      final nodeStart = project.nodes.firstWhere(
        (n) => n.id == element.nodeStartId,
      );
      final nodeEnd = project.nodes.firstWhere(
        (n) => n.id == element.nodeEndId,
      );

      final nodeStartResult = calculationResult.nodeResults
          .firstWhere((n) => n.nodeId == nodeStart.id);
      final nodeEndResult = calculationResult.nodeResults
          .firstWhere((n) => n.nodeId == nodeEnd.id);

      final uStart = nodeStartResult.displacement;
      final uEnd = nodeEndResult.displacement;
      final E = element.E;
      final A = element.A;
      final L = (nodeEnd.x - nodeStart.x).abs();
      final qx = element.qx;

      /// ✅ ТА ЖЕ ИСПРАВЛЕННАЯ ФОРМУЛА
      final Nx_avg = (E * A / L) * (uEnd - uStart);
      final NxAtStart = Nx_avg + qx * L / 2;

      final xStart = nodeStart.x;
      const int subdivisions = 30;

      for (int i = 0; i <= subdivisions; i++) {
        final ratio = i / subdivisions;
        final localCoord = ratio * L;
        final globalX = xStart + localCoord;

        final NxValue = NxAtStart - qx * localCoord;
        final sigma = A > 0 ? NxValue / A : 0.0;
        final epsilon = E > 0 ? sigma / E : 0.0;

        points.add(DiagramPoint(
          x: globalX,
          value: epsilon,
          elementId: element.id,
          isNode: (i == 0 || i == subdivisions),
        ));

        values.add(epsilon);
      }
    }

    if (points.isEmpty) {
      return DiagramModel(
        name: 'ε',
        unit: 'безразм',
        points: [],
        maxValue: 0.0,
        minValue: 0.0,
        averageValue: 0.0,
      );
    }

    points.sort((a, b) => a.x.compareTo(b.x));
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
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

  /// ✅ Анализ прочности (без изменений)
  List<ElementStressAnalysis> analyzeStress() {
    if (!calculationResult.isSuccessful) {
      throw Exception('Расчёт не был выполнен успешно');
    }

    final analysis = <ElementStressAnalysis>[];

    for (var elemResult in calculationResult.elementResults) {
      final element = project.elements
          .firstWhere((e) => e.id == elemResult.elementId);

      final actualStress = elemResult.stress.abs();
      final allowableStress = element.allowableStress;
      final isPassed = actualStress <= allowableStress;
      final safetyFactor = actualStress > 0
          ? allowableStress / actualStress
          : double.infinity;

      String status = 'OK';
      if (safetyFactor <= 1.0) {
        status = 'DANGER';
      } else if (safetyFactor <= 2.0) {
        status = 'WARNING';
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

/// Все эпюры конструкции
class AllDiagrams {
  final DiagramModel internalForces;
  final DiagramModel stresses;
  final DiagramModel displacements;
  final DiagramModel strains;

  AllDiagrams({
    required this.internalForces,
    required this.stresses,
    required this.displacements,
    required this.strains,
  });
}