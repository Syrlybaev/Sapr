// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';

/// Данные для точки на эпюре
class DiagramPoint extends Equatable {
  final double x; // Глобальная координата
  final double value; // Значение (Nx, σ, Δ, ε)
  final int elementId; // ID стержня для отслеживания

  const DiagramPoint({
    required this.x,
    required this.value,
    required this.elementId,
  });

  @override
  List<Object?> get props => [x, value, elementId];
}

/// Модель эпюры для одного типа компоненты
class DiagramModel extends Equatable {
  final String name; // 'Nx', 'σx', 'Δ', 'ε'
  final String unit; // 'Н', 'МПа', 'м', 'безразм'
  final List<DiagramPoint> points; // Точки эпюры
  final double maxValue; // Максимальное значение
  final double minValue; // Минимальное значение
  final double averageValue; // Среднее значение

  const DiagramModel({
    required this.name,
    required this.unit,
    required this.points,
    required this.maxValue,
    required this.minValue,
    required this.averageValue,
  });

  @override
  List<Object?> get props =>
      [name, unit, points, maxValue, minValue, averageValue];

  /// Получить точку диаграммы по стержню
  DiagramPoint? getPointByElement(int elementId) {
    try {
      return points.firstWhere((p) => p.elementId == elementId);
    } catch (e) {
      return null;
    }
  }
}

/// Все эпюры конструкции
class AllDiagrams extends Equatable {
  final DiagramModel internalForces; // Nx
  final DiagramModel stresses; // σx
  final DiagramModel displacements; // Δ
  final DiagramModel strains; // ε

  const AllDiagrams({
    required this.internalForces,
    required this.stresses,
    required this.displacements,
    required this.strains,
  });

  @override
  List<Object?> get props =>
      [internalForces, stresses, displacements, strains];
}
