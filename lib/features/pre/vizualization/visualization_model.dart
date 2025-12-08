import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:saprbar_desktop/core/models/node_model.dart';
import 'package:saprbar_desktop/core/models/element_model.dart';

/// Модель для визуализации конструкции
class VisualizationModel extends Equatable {
  final List<NodeModel> nodes;
  final List<ElementModel> elements;
  final bool fixLeft; // ← NEW
  final bool fixRight; // ← NEW

  // Параметры визуализации
  final double padding;
  final double nodeRadius;
  final double scale;
  final Offset offset;

  // Параметры для нагрузок
  final double distributedLoadArrowHeight;
  final int distributedLoadArrowCount;
  final double maxSectionHeightPixels;

  const VisualizationModel({
    required this.nodes,
    required this.elements,
    this.padding = 40.0,
    this.nodeRadius = 3.5,
    this.scale = 50.0,
    this.offset = const Offset(0, 0),
    this.distributedLoadArrowHeight = 18.0,
    this.distributedLoadArrowCount = 4,
    this.maxSectionHeightPixels = 60.0,
    this.fixLeft = false, 
    this.fixRight = false, 
  });

  /// Преобразование координаты X в пиксели
  double xToPixel(double x) => x * scale + offset.dx + padding;

  /// Y для визуализации (центр конструкции)
  double get centerY => offset.dy + padding;

  /// Вычисляем границы конструкции
  (double, double) getXBounds() {
    if (nodes.isEmpty) return (0, 100);
    final xValues = nodes.map((n) => n.x).toList();
    return (
      xValues.reduce((a, b) => a < b ? a : b),
      xValues.reduce((a, b) => a > b ? a : b),
    );
  }

  /// Получить визуальную высоту сечения на основе площади
  double getVisualSectionHeight(double area, double maxArea) {
    if (maxArea <= 0 || area <= 0) return 4.0;
    final ratio = (area / maxArea).clamp(0, 1);
    return 4.0 + ratio * (maxSectionHeightPixels - 4.0);
  }

  VisualizationModel copyWith({
    List<NodeModel>? nodes,
    List<ElementModel>? elements,
    double? padding,
    double? nodeRadius,
    double? scale,
    Offset? offset,
    double? distributedLoadArrowHeight,
    int? distributedLoadArrowCount,
    double? maxSectionHeightPixels,
  }) {
    return VisualizationModel(
      nodes: nodes ?? this.nodes,
      elements: elements ?? this.elements,
      padding: padding ?? this.padding,
      nodeRadius: nodeRadius ?? this.nodeRadius,
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      distributedLoadArrowHeight:
          distributedLoadArrowHeight ?? this.distributedLoadArrowHeight,
      distributedLoadArrowCount:
          distributedLoadArrowCount ?? this.distributedLoadArrowCount,
      maxSectionHeightPixels:
          maxSectionHeightPixels ?? this.maxSectionHeightPixels,
    );
  }

  @override
  List<Object?> get props => [
    nodes,
    elements,
    padding,
    nodeRadius,
    scale,
    offset,
    distributedLoadArrowHeight,
    distributedLoadArrowCount,
    maxSectionHeightPixels,
  ];
}
