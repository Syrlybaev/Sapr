// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';

/// Сущность эпюры для доменного слоя
class DiagramEntity extends Equatable {
  final String name; // 'Nx', 'σx', 'Δ', 'ε'
  final String unit; // 'Н', 'МПа', 'м', 'безразм'
  final List<DiagramPointEntity> points;
  final double maxValue;
  final double minValue;
  final double averageValue;

  const DiagramEntity({
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
}

/// Точка на эпюре
class DiagramPointEntity extends Equatable {
  final double x; // Координата
  final double value; // Значение
  final int elementId; // ID стержня

  const DiagramPointEntity({
    required this.x,
    required this.value,
    required this.elementId,
  });

  @override
  List<Object?> get props => [x, value, elementId];
}
