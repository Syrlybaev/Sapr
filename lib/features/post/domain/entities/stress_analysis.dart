import 'package:equatable/equatable.dart';

/// Результат анализа прочности одного стержня
class ElementStressAnalysis extends Equatable {
  final int elementId;
  final double stress; // Максимальное напряжение на стержне
  final double allowableStress; // Допускаемое напряжение
  final bool isPassed; // true если прочность обеспечена
  final double safetyFactor; // Коэффициент запаса: allowable / actual
  final String status; // 'OK', 'WARNING', 'DANGER'

  const ElementStressAnalysis({
    required this.elementId,
    required this.stress,
    required this.allowableStress,
    required this.isPassed,
    required this.safetyFactor,
    required this.status,
  });

  @override
  List<Object?> get props => [
        elementId,
        stress,
        allowableStress,
        isPassed,
        safetyFactor,
        status,
      ];
}

/// Общий анализ прочности всей конструкции
class StressAnalysisReport extends Equatable {
  final List<ElementStressAnalysis> elementAnalyses;
  final bool isConstructionSafe; // true если все стержни прочны
  final int passedCount; // Количество стержней, прошедших проверку
  final int failedCount; // Количество стержней, не прошедших проверку
  final double minSafetyFactor; // Минимальный коэффициент запаса
  final int criticalElementId; // ID стержня с наименьшим запасом

  const StressAnalysisReport({
    required this.elementAnalyses,
    required this.isConstructionSafe,
    required this.passedCount,
    required this.failedCount,
    required this.minSafetyFactor,
    required this.criticalElementId,
  });

  @override
  List<Object?> get props => [
        elementAnalyses,
        isConstructionSafe,
        passedCount,
        failedCount,
        minSafetyFactor,
        criticalElementId,
      ];
}
