// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:saprbar_desktop/core/models/project_model.dart';
import 'package:saprbar_desktop/features/post/data/datasources/post_calculator.dart';
import 'package:saprbar_desktop/features/pro/data/models/calculation_result_model.dart';

/// Генератор отчетов
class ReportGenerator {
  final ProjectModel project;
  final CalculationResultModel calculationResult;

  ReportGenerator({
    required this.project,
    required this.calculationResult,
  });

  /// Генерация полного отчета в формате JSON
  String generateJsonReport() {
    final calculator = PostCalculator(
      project: project,
      calculationResult: calculationResult,
    );

    final stressAnalysis = calculator.analyzeStress();

    final report = {
      'projectName': project.name,
      'calculatedAt': calculationResult.calculatedAt.toIso8601String(),
      'structure': {
        'nodes': project.nodes.map((n) => {
              'id': n.id,
              'x': n.x,
              'loadX': n.loadX,
              'loadY': n.loadY,
            }).toList(),
        'elements': project.elements.map((e) => {
              'id': e.id,
              'nodeStart': e.nodeStartId,
              'nodeEnd': e.nodeEndId,
              'E': e.E,
              'A': e.A,
              'allowableStress': e.allowableStress,
              'qx': e.qx,
              'qy': e.qy,
            }).toList(),
      },
      'results': {
        'nodeResults': calculationResult.nodeResults.map((n) => {
              'nodeId': n.nodeId,
              'displacement': n.displacement,
              'loadX': n.loadX,
            }).toList(),
        'elementResults': calculationResult.elementResults.map((e) => {
              'elementId': e.elementId,
              'internalForce': e.internalForce,
              'stress': e.stress,
              'strain': e.strain,
            }).toList(),
      },
      'stressAnalysis': {
        'elements': stressAnalysis.map((e) => {
              'elementId': e.elementId,
              'stress': e.stress,
              'allowableStress': e.allowableStress,
              'safetyFactor': e.safetyFactor,
              'status': e.status,
              'passed': e.isPassed,
            }).toList(),
        'summary': {
          'passedCount': stressAnalysis.where((e) => e.isPassed).length,
          'failedCount': stressAnalysis.where((e) => !e.isPassed).length,
          'isConstructionSafe':
              stressAnalysis.every((e) => e.isPassed),
          'minSafetyFactor': stressAnalysis.isEmpty
              ? 0
              : stressAnalysis.map((e) => e.safetyFactor).reduce((a, b) =>
                  a < b ? a : b),
        },
      },
    };

    return _prettyPrintJson(report);
  }

  /// Генерация текстового отчета
  String generateTextReport() {
    final calculator = PostCalculator(
      project: project,
      calculationResult: calculationResult,
    );

    final stressAnalysis = calculator.analyzeStress();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');
    final date = dateFormat.format(calculationResult.calculatedAt);

    final buffer = StringBuffer();

    // Заголовок
    buffer.writeln('╔════════════════════════════════════════════════════════════════╗');
    buffer.writeln('║                      ОТЧЕТ О РАСЧЕТЕ                            ║');
    buffer.writeln('╚════════════════════════════════════════════════════════════════╝');
    buffer.writeln();

    // Информация о проекте
    buffer.writeln('📋 ИНФОРМАЦИЯ О ПРОЕКТЕ');
    buffer.writeln('─' * 65);
    buffer.writeln('Название: ${project.name}');
    buffer.writeln('Время расчета: $date');
    buffer.writeln();

    // Конструкция
    buffer.writeln('🏗️  КОНСТРУКЦИЯ');
    buffer.writeln('─' * 65);
    buffer.writeln('Узлов: ${project.nodes.length}');
    buffer.writeln('Стержней: ${project.elements.length}');
    buffer.writeln();

    // Результаты в узлах
    buffer.writeln('📍 РЕЗУЛЬТАТЫ В УЗЛАХ');
    buffer.writeln('─' * 65);
    buffer.writeln(
        '${' ID'.padRight(6)} │ ${' X (м)'.padRight(12)} │ ${'Δ (м)'.padRight(15)} │ ${'F (Н)'.padRight(12)}');
    buffer.writeln('─' * 65);

    for (var nodeResult in calculationResult.nodeResults) {
      final node = project.nodes.firstWhere((n) => n.id == nodeResult.nodeId);
      buffer.writeln(
          '${nodeResult.nodeId.toString().padRight(6)} │ ${(node.x).toStringAsFixed(6).padRight(12)} │ ${nodeResult.displacement.toStringAsFixed(8).padRight(15)} │ ${nodeResult.loadX.toStringAsFixed(2).padRight(12)}');
    }
    buffer.writeln();

    // Результаты в стержнях
    buffer.writeln('📊 РЕЗУЛЬТАТЫ В СТЕРЖНЯХ');
    buffer.writeln('─' * 65);
    buffer.writeln(
        '${' ID'.padRight(6)} │ ${' N (Н)'.padRight(12)} │ ${' σ (МПа)'.padRight(12)} │ ${'ε'.padRight(12)}');
    buffer.writeln('─' * 65);

    for (var elemResult in calculationResult.elementResults) {
      final sign = elemResult.internalForce >= 0 ? '+' : '';
      buffer.writeln(
          '${elemResult.elementId.toString().padRight(6)} │ ${(sign + elemResult.internalForce.toStringAsFixed(2)).padRight(12)} │ ${elemResult.stress.toStringAsFixed(3).padRight(12)} │ ${elemResult.strain.toStringAsFixed(6).padRight(12)}');
    }
    buffer.writeln();

    // Анализ прочности
    buffer.writeln('✅ АНАЛИЗ ПРОЧНОСТИ');
    buffer.writeln('─' * 65);

    final passedCount = stressAnalysis.where((e) => e.isPassed).length;
    final failedCount = stressAnalysis.where((e) => !e.isPassed).length;
    final minSafetyFactor = stressAnalysis.isEmpty
        ? 0.0
        : stressAnalysis.map((e) => e.safetyFactor).reduce((a, b) =>
            a < b ? a : b);

    buffer.writeln('Пройдено проверку: $passedCount/${stressAnalysis.length}');
    buffer.writeln('Не пройдено: $failedCount/${stressAnalysis.length}');
    buffer.writeln('Минимальный коэффициент запаса: ${minSafetyFactor.toStringAsFixed(3)}');
    buffer.writeln(
        'Статус конструкции: ${stressAnalysis.every((e) => e.isPassed) ? '✓ ПРОЧНОСТЬ ОБЕСПЕЧЕНА' : '✗ ТРЕБУЕТСЯ УСИЛЕНИЕ'}');
    buffer.writeln();

    // Таблица анализа
    buffer.writeln('📋 ДЕТАЛЬНЫЙ АНАЛИЗ ПРОЧНОСТИ');
    buffer.writeln('─' * 80);
    buffer.writeln(
        '${' ID'.padRight(6)} │ ${'σ (МПа)'.padRight(12)} │ ${'[σ] (МПа)'.padRight(12)} │ ${'Коэфф. запаса'.padRight(14)} │ ${'Статус'.padRight(8)}');
    buffer.writeln('─' * 80);

    for (var stress in stressAnalysis) {
      final statusSymbol =
          stress.isPassed ? '✓ OK' : '✗ FAIL';
      buffer.writeln(
          '${stress.elementId.toString().padRight(6)} │ ${stress.stress.toStringAsFixed(3).padRight(12)} │ ${stress.allowableStress.toStringAsFixed(3).padRight(12)} │ ${stress.safetyFactor.toStringAsFixed(3).padRight(14)} │ ${statusSymbol.padRight(8)}');
    }
    buffer.writeln();

    buffer.writeln('╔════════════════════════════════════════════════════════════════╗');
    buffer.writeln('║                       КОНЕЦ ОТЧЕТА                            ║');
    buffer.writeln('╚════════════════════════════════════════════════════════════════╝');

    return buffer.toString();
  }

  /// Сохранить отчет в файл
  Future<File> saveReportToFile({
    required String filePath,
    bool asJson = false,
  }) async {
    final file = File(filePath);
    final content = asJson ? generateJsonReport() : generateTextReport();

    await file.writeAsString(content);
    return file;
  }

  /// Pretty print JSON
  String _prettyPrintJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }
}
