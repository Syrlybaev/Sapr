// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:saprbar_desktop/core/models/project_model.dart';
import 'package:saprbar_desktop/features/post/data/models/diagram_model.dart';
import 'package:saprbar_desktop/features/post/domain/entities/stress_analysis.dart';
import 'package:saprbar_desktop/features/pro/data/models/calculation_result_model.dart';

/// Генератор отчётов для постпроцессора
class PostReportGenerator {
  final ProjectModel project;
  final CalculationResultModel calculationResult;
  final List<ElementStressAnalysis> stressAnalysis;
  final AllDiagrams diagrams;

  PostReportGenerator({
    required this.project,
    required this.calculationResult,
    required this.stressAnalysis,
    required this.diagrams,
  });

  /// Сгенерировать текстовый отчёт
  String generateTextReport() {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final dateFormatter = DateFormat('dd.MM.yyyy HH:mm:ss');

    buffer.writeln('═' * 80);
    buffer.writeln('ОТЧЁТ ПО РЕЗУЛЬТАТАМ РАСЧЁТА СТЕРЖНЕВОЙ КОНСТРУКЦИИ');
    buffer.writeln('═' * 80);
    buffer.writeln();

    // Заголовок
    buffer.writeln('Проект: ${project.name}');
    buffer.writeln('Дата отчёта: ${dateFormatter.format(now)}');
    buffer.writeln();

    // Информация о конструкции
    buffer.writeln('╔ ИНФОРМАЦИЯ О КОНСТРУКЦИИ');
    buffer.writeln('├─ Количество узлов: ${project.nodes.length}');
    buffer.writeln('├─ Количество стержней: ${project.elements.length}');
    buffer.writeln(
        '└─ Статус расчёта: ${calculationResult.isSuccessful ? '✓ УСПЕШНО' : '✗ ОШИБКА'}');
    buffer.writeln();

    // Узлы конструкции
    buffer.writeln('╔ УЗЛЫ КОНСТРУКЦИИ');
    buffer.writeln('├─────┬────────┬──────────────┬──────────────┐');
    buffer.writeln('│ ID  │   x    │  LoadX [Н]   │  LoadY [Н]   │');
    buffer.writeln('├─────┼────────┼──────────────┼──────────────┤');

    for (var node in project.nodes) {
      buffer.writeln(
        '│ ${node.id.toString().padRight(3)} │ ${node.x.toStringAsFixed(2).padRight(6)} │ ${node.loadX.toStringAsFixed(2).padRight(12)} │ ${node.loadY.toStringAsFixed(2).padRight(12)} │',
      );
    }
    buffer.writeln('└─────┴────────┴──────────────┴──────────────┘');
    buffer.writeln();

    // Стержни конструкции
    buffer.writeln('╔ СТЕРЖНИ КОНСТРУКЦИИ');
    buffer.writeln('├────┬──────────┬──────────┬──────────┬────────────┐');
    buffer.writeln('│ ID │ От-До    │ qx Н/м   │ A [м²]   │ E [МПа]    │');
    buffer.writeln('├────┼──────────┼──────────┼──────────┼────────────┤');

    for (var element in project.elements) {
      buffer.writeln(
        '│ ${element.id.toString().padRight(2)} │ ${element.nodeStartId}-${element.nodeEndId} │ ${element.qx.toStringAsFixed(2).padRight(8)} │ ${element.A.toStringAsFixed(6).padRight(8)} │ ${element.E.toStringAsFixed(0).padRight(10)} │',
      );
    }
    buffer.writeln('└────┴──────────┴──────────┴──────────┴────────────┘');
    buffer.writeln();

    // Результаты расчёта для узлов
    buffer.writeln('╔ РЕЗУЛЬТАТЫ ДЛЯ УЗЛОВ');
    buffer.writeln('├─────┬──────────────────┬──────────────┐');
    buffer.writeln('│ ID  │  Перемещ. Δ [м]  │  LoadX [Н]   │');
    buffer.writeln('├─────┼──────────────────┼──────────────┤');

    for (var nodeResult in calculationResult.nodeResults) {
      buffer.writeln(
        '│ ${nodeResult.nodeId.toString().padRight(3)} │ ${nodeResult.displacement.toStringAsFixed(8).padRight(16)} │ ${nodeResult.loadX.toStringAsFixed(2).padRight(12)} │',
      );
    }
    buffer.writeln('└─────┴──────────────────┴──────────────┘');
    buffer.writeln();

    // Результаты по стержням
    buffer.writeln('╔ РЕЗУЛЬТАТЫ ДЛЯ СТЕРЖНЕЙ');
    buffer.writeln('├────┬──────────────┬────────────┬──────────────┐');
    buffer.writeln('│ ID │ Nx [Н]       │ σ [МПа]    │ ε [безразм]  │');
    buffer.writeln('├────┼──────────────┼────────────┼──────────────┤');

    for (var elemResult in calculationResult.elementResults) {
      buffer.writeln(
        '│ ${elemResult.elementId.toString().padRight(2)} │ ${elemResult.internalForce.toStringAsFixed(2).padRight(12)} │ ${elemResult.stress.toStringAsFixed(4).padRight(10)} │ ${elemResult.strain.toStringAsFixed(8).padRight(12)} │',
      );
    }
    buffer.writeln('└────┴──────────────┴────────────┴──────────────┘');
    buffer.writeln();

    // Анализ прочности
    buffer.writeln('╔ АНАЛИЗ ПРОЧНОСТИ');
    final passedCount = stressAnalysis.where((a) => a.isPassed).length;
    final failedCount = stressAnalysis.length - passedCount;
    final minSafetyFactor = stressAnalysis.isNotEmpty
        ? stressAnalysis.map((a) => a.safetyFactor).reduce((a, b) => a < b ? a : b)
        : 0.0;

    buffer.writeln('├─ Стержней в норме: $passedCount/${stressAnalysis.length}');
    buffer.writeln('├─ Стержней с проблемами: $failedCount');
    buffer.writeln(
        '├─ Минимальный коэффициент запаса: ${minSafetyFactor.toStringAsFixed(3)}');
    buffer.writeln(
      '└─ Конструкция: ${passedCount == stressAnalysis.length ? '✓ ПРОЧНА' : '✗ ТРЕБУЕТ УСИЛЕНИЯ'}',
    );
    buffer.writeln();

    // Таблица анализа
    if (stressAnalysis.isNotEmpty) {
      buffer.writeln('╔ ТАБЛИЦА АНАЛИЗА ПРОЧНОСТИ');
      buffer.writeln('├────┬──────────────┬─────────────┬────────────┬────────────┐');
      buffer.writeln(
        '│ ID │ σ факт [МПа] │ σ доп [МПа] │ Коэфф. Запа │ Статус     │',
      );
      buffer.writeln('├────┼──────────────┼─────────────┼────────────┼────────────┤');

      for (var analysis in stressAnalysis) {
        buffer.writeln(
          '│ ${analysis.elementId.toString().padRight(2)} │ ${analysis.stress.toStringAsFixed(3).padRight(12)} │ ${analysis.allowableStress.toStringAsFixed(2).padRight(11)} │ ${analysis.safetyFactor.toStringAsFixed(3).padRight(10)} │ ${analysis.status.padRight(10)} │',
        );
      }
      buffer.writeln('└────┴──────────────┴─────────────┴────────────┴────────────┘');
    }
    buffer.writeln();

    // Информация об эпюрах
    buffer.writeln('╔ СТАТИСТИКА ЭПЮР');
    buffer.writeln('├─ Эпюра Nx: ${diagrams.internalForces.points.length} точек');
    buffer.writeln(
        '│  ├─ Макс: ${diagrams.internalForces.maxValue.toStringAsFixed(2)} Н');
    buffer.writeln(
        '│  ├─ Мин: ${diagrams.internalForces.minValue.toStringAsFixed(2)} Н');
    buffer.writeln(
        '│  └─ Средн: ${diagrams.internalForces.averageValue.toStringAsFixed(2)} Н');
    buffer.writeln();

    buffer.writeln('├─ Эпюра σx: ${diagrams.stresses.points.length} точек');
    buffer.writeln(
        '│  ├─ Макс: ${diagrams.stresses.maxValue.toStringAsFixed(3)} МПа');
    buffer.writeln(
        '│  ├─ Мин: ${diagrams.stresses.minValue.toStringAsFixed(3)} МПа');
    buffer.writeln(
        '│  └─ Средн: ${diagrams.stresses.averageValue.toStringAsFixed(3)} МПа');
    buffer.writeln();

    buffer.writeln('├─ Эпюра Δ: ${diagrams.displacements.points.length} точек');
    buffer.writeln(
        '│  ├─ Макс: ${diagrams.displacements.maxValue.toStringAsFixed(8)} м');
    buffer.writeln(
        '│  ├─ Мин: ${diagrams.displacements.minValue.toStringAsFixed(8)} м');
    buffer.writeln(
        '│  └─ Средн: ${diagrams.displacements.averageValue.toStringAsFixed(8)} м');
    buffer.writeln();

    buffer.writeln('└─ Эпюра ε: ${diagrams.strains.points.length} точек');
    buffer.writeln(
        '   ├─ Макс: ${diagrams.strains.maxValue.toStringAsFixed(8)}');
    buffer.writeln(
        '   ├─ Мин: ${diagrams.strains.minValue.toStringAsFixed(8)}');
    buffer.writeln(
        '   └─ Средн: ${diagrams.strains.averageValue.toStringAsFixed(8)}');
    buffer.writeln();

    buffer.writeln('═' * 80);
    buffer.writeln('Конец отчёта');
    buffer.writeln('═' * 80);

    return buffer.toString();
  }

  /// Сгенерировать JSON отчёт
  String generateJsonReport() {
    final report = {
      'metadata': {
        'projectName': project.name,
        'generatedAt': DateTime.now().toIso8601String(),
        'calculationStatus': calculationResult.isSuccessful ? 'success' : 'failed',
      },
      'construction': {
        'nodesCount': project.nodes.length,
        'elementsCount': project.elements.length,
        'fixLeft': project.fixLeft,
        'fixRight': project.fixRight,
        'nodes': [
          for (var node in project.nodes)
            {
              'id': node.id,
              'x': node.x,
              'loadX': node.loadX,
              'loadY': node.loadY,
            }
        ],
        'elements': [
          for (var elem in project.elements)
            {
              'id': elem.id,
              'nodeStartId': elem.nodeStartId,
              'nodeEndId': elem.nodeEndId,
              'qx': elem.qx,
              'E': elem.E,
              'A': elem.A,
              'allowableStress': elem.allowableStress,
            }
        ],
      },
      'nodeResults': [
        for (var nodeResult in calculationResult.nodeResults)
          {
            'nodeId': nodeResult.nodeId,
            'displacement': nodeResult.displacement,
            'loadX': nodeResult.loadX,
          }
      ],
      'elementResults': [
        for (var elemResult in calculationResult.elementResults)
          {
            'elementId': elemResult.elementId,
            'internalForce': elemResult.internalForce,
            'stress': elemResult.stress,
            'strain': elemResult.strain,
          }
      ],
      'stressAnalysis': [
        for (var analysis in stressAnalysis)
          {
            'elementId': analysis.elementId,
            'actualStress': analysis.stress,
            'allowableStress': analysis.allowableStress,
            'safetyFactor': analysis.safetyFactor,
            'status': analysis.status,
            'isPassed': analysis.isPassed,
          }
      ],
      'diagramsStatistics': {
        'internalForces': _diagramToJson(diagrams.internalForces),
        'stresses': _diagramToJson(diagrams.stresses),
        'displacements': _diagramToJson(diagrams.displacements),
        'strains': _diagramToJson(diagrams.strains),
      },
    };

    return jsonEncode(report);
  }

  Map<String, dynamic> _diagramToJson(DiagramModel diagram) {
    return {
      'name': diagram.name,
      'unit': diagram.unit,
      'pointsCount': diagram.points.length,
      'maxValue': diagram.maxValue,
      'minValue': diagram.minValue,
      'averageValue': diagram.averageValue,
      'points': [
        for (var point in diagram.points)
          {
            'x': point.x,
            'value': point.value,
            'elementId': point.elementId,
          }
      ],
    };
  }

  /// Экспортировать отчёт в файл
  Future<File> exportToFile(
    String directoryPath, {
    bool asJson = false,
  }) async {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final fileName =
        '${project.name}_report_$timestamp.${asJson ? 'json' : 'txt'}';
    final filePath = '$directoryPath/$fileName';

    final file = File(filePath);
    final content = asJson ? generateJsonReport() : generateTextReport();

    await file.writeAsString(content);
    return file;
  }
}
