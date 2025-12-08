import 'package:flutter/material.dart';
import 'dart:math';
import 'package:saprbar_desktop/core/models/node_model.dart';
import 'package:saprbar_desktop/features/pre/vizualization/visualization_model.dart';

class VisualizationPainter extends CustomPainter {
  final VisualizationModel model;

  final Paint axisPaint =
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 1.0;

  final Paint centerLinePaint =
      Paint()
        ..color = Colors.grey.shade500
        ..strokeWidth = 0.5;

  final Paint sectionFillPaint =
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;

  final Paint sectionStrokePaint =
      Paint()
        ..color = Colors.blue
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

  final Paint nodePaint =
      Paint()
        ..color = Colors.blue
        ..strokeWidth = 2.0;

  final Paint fixedNodePaint =
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2.0;

  final Paint pointLoadPaint =
      Paint()
        ..color = Colors.orange
        ..strokeWidth = 3.0;

  final Paint distribLoadPaint =
      Paint()
        ..color = Colors.green
        ..strokeWidth = 2.5;

  final Paint longitudinalLoadPaint =
      Paint()
        ..color = Colors.amber
        ..strokeWidth = 2.5;

  VisualizationPainter(this.model);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.grey.shade800,
    );

    if (model.nodes.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }

    _drawCenterLine(canvas);
    _drawAxis(canvas);
    _drawElements(canvas);
    _drawDistributedLoads(canvas);
    _drawLongitudinalLoads(canvas);
    _drawNodes(canvas);
    _drawPointLoads(canvas);
    _drawSupports(canvas);
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Добавьте узлы для визуализации конструкции',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2, size.height / 2),
    );
  }

  void _drawCenterLine(Canvas canvas) {
    if (model.nodes.length < 2) return;
    final xMin = model.xToPixel(model.nodes.first.x);
    final xMax = model.xToPixel(model.nodes.last.x);
    final y = model.centerY;
    _drawDashedLine(
      canvas,
      Offset(xMin - 50, y),
      Offset(xMax + 50, y),
      centerLinePaint,
    );
  }

  void _drawAxis(Canvas canvas) {
    if (model.nodes.length < 2) return;
    final xMin = model.xToPixel(model.nodes.first.x);
    final xMax = model.xToPixel(model.nodes.last.x);
    final y = model.centerY;
    canvas.drawLine(Offset(xMin, y), Offset(xMax, y), axisPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final steps = (distance / 10).toInt();

    for (int i = 0; i < steps; i++) {
      final t1 = i / steps;
      final t2 = (i + 0.5) / steps;
      final p1 = Offset(start.dx + dx * t1, start.dy + dy * t1);
      final p2 = Offset(start.dx + dx * t2, start.dy + dy * t2);
      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawElements(Canvas canvas) {
    if (model.elements.isEmpty) return;
    double maxArea = 0;
    for (final element in model.elements) {
      if (element.A > maxArea) maxArea = element.A;
    }
    if (maxArea == 0) maxArea = 1;

    for (final element in model.elements) {
      final startNode = model.nodes.firstWhere(
        (n) => n.id == element.nodeStartId,
        orElse: () => NodeModel(id: -1, x: 0),
      );
      final endNode = model.nodes.firstWhere(
        (n) => n.id == element.nodeEndId,
        orElse: () => NodeModel(id: -1, x: 0),
      );

      final x1 = model.xToPixel(startNode.x);
      final x2 = model.xToPixel(endNode.x);
      final y = model.centerY;
      final visualHeight = model.getVisualSectionHeight(element.A, maxArea);

      final rect = Rect.fromLTRB(
        x1,
        y - visualHeight / 2,
        x2,
        y + visualHeight / 2,
      );
      canvas.drawRect(rect, sectionFillPaint);
      canvas.drawRect(rect, sectionStrokePaint);
    }
  }

  /// Поперечная нагрузка qy (вверх/вниз)
  void _drawDistributedLoads(Canvas canvas) {
    for (final element in model.elements) {
      if (element.qy == 0) continue;

      final startNode = model.nodes.firstWhere(
        (n) => n.id == element.nodeStartId,
        orElse: () => NodeModel(id: -1, x: 0),
      );
      final endNode = model.nodes.firstWhere(
        (n) => n.id == element.nodeEndId,
        orElse: () => NodeModel(id: -1, x: 0),
      );

      final x1 = model.xToPixel(startNode.x);
      final x2 = model.xToPixel(endNode.x);
      final y = model.centerY; // ← Центральная ось
      final arrowHeight = model.distributedLoadArrowHeight;

      for (int i = 0; i <= model.distributedLoadArrowCount; i++) {
        final t = i / model.distributedLoadArrowCount;
        final xPos = x1 + (x2 - x1) * t;

        // qy > 0 = вверх (стрелка идёт ВВЕРХ)
        // qy < 0 = вниз (стрелка идёт ВНИЗ)
        final isPositive = element.qy > 0;

        // Стрелка ВСЕГДА начинается с центральной оси (y)
        final startY = y;
        final endY = y + (isPositive ? -arrowHeight : arrowHeight);

        canvas.drawLine(
          Offset(xPos, startY),
          Offset(xPos, endY),
          distribLoadPaint,
        );

        // Стрелка указывает в ту же сторону, что и направление нагрузки
        _drawArrowHeadVertical(
          canvas,
          Offset(xPos, endY),
          isPositive ? -1 : 1, // ← -1 для вверх, 1 для вниз
          distribLoadPaint,
        );
      }

      // Текст подписи
      final textOffsetX = (x1 + x2) / 2 - 40;
      final textOffsetY =
          element.qy > 0
              ? y -
                  arrowHeight -
                  18 // Выше стрелок если вверх
              : y + arrowHeight + 8; // Ниже стрелок если вниз

      _drawText(
        canvas,
        'qy=${element.qy.toStringAsFixed(1)} Н/м',
        Offset(textOffsetX, textOffsetY),
        Colors.green,
        fontSize: 10,
      );
    }
  }

  /// Продольная нагрузка qx (вдоль оси стержня)
  void _drawLongitudinalLoads(Canvas canvas) {
    for (final element in model.elements) {
      if (element.qx == 0) continue;

      final startNode = model.nodes.firstWhere(
        (n) => n.id == element.nodeStartId,
        orElse: () => NodeModel(id: -1, x: 0),
      );
      final endNode = model.nodes.firstWhere(
        (n) => n.id == element.nodeEndId,
        orElse: () => NodeModel(id: -1, x: 0),
      );

      final x1 = model.xToPixel(startNode.x);
      final x2 = model.xToPixel(endNode.x);
      final y = model.centerY;

      const int arrowCount = 3;
      const double arrowSize = 12;
      const double arrowHeadSize = 8;

      for (int i = 1; i <= arrowCount; i++) {
        final t = i / (arrowCount + 1);
        final xPos = x1 + (x2 - x1) * t;

        final direction = element.qx > 0 ? 1 : -1;

        final lineStart = xPos - direction * (arrowSize - arrowHeadSize) / 2;
        final lineEnd = xPos + direction * (arrowSize - arrowHeadSize) / 2;

        canvas.drawLine(
          Offset(lineStart, y),
          Offset(lineEnd, y),
          longitudinalLoadPaint,
        );
        _drawArrowHeadHorizontal(
          canvas,
          Offset(lineEnd, y),
          direction,
          longitudinalLoadPaint,
        );
      }

      _drawText(
        canvas,
        'qx=${element.qx.toStringAsFixed(1)} Н/м',
        Offset((x1 + x2) / 2 - 35, y - 20),
        Colors.amber,
        fontSize: 10,
      );
    }
  }

  void _drawNodes(Canvas canvas) {
    for (final node in model.nodes) {
      final x = model.xToPixel(node.x);
      final y = model.centerY + node.y * model.scale;

      final isFixed =
          (node.id == 1 && model.fixLeft) ||
          (node.id == model.nodes.length && model.fixRight);
      final paint = isFixed ? fixedNodePaint : nodePaint;

      canvas.drawCircle(Offset(x, y), model.nodeRadius, paint);
      _drawText(
        canvas,
        'N${node.id}',
        Offset(x - 8, y - 14),
        Colors.white,
        fontSize: 11,
      );
    }
  }

  void _drawPointLoads(Canvas canvas) {
    const double arrowSize = 22;

    for (final node in model.nodes) {
      final x = model.xToPixel(node.x);
      final y = model.centerY + node.y * model.scale;

      // Нагрузка Fx
      if (node.loadX != 0) {
        final direction = node.loadX > 0 ? 1 : -1;

        final startX = x;
        final endX = x + direction * arrowSize;

        canvas.drawLine(Offset(startX, y), Offset(endX, y), pointLoadPaint);
        _drawArrowHeadHorizontal(
          canvas,
          Offset(endX, y),
          direction,
          pointLoadPaint,
        );

        _drawText(
          canvas,
          'Fx=${node.loadX.toStringAsFixed(0)}',
          Offset(x + direction * arrowSize / 2 - 25, y + 12),
          Colors.orange,
          fontSize: 9,
        );
      }

      // Нагрузка Fy
      if (node.loadY != 0) {
        final direction = node.loadY > 0 ? -1 : 1;

        final startY = y;
        final endY = y + direction * arrowSize;

        canvas.drawLine(Offset(x, startY), Offset(x, endY), pointLoadPaint);
        _drawArrowHeadVertical(
          canvas,
          Offset(x, endY),
          direction,
          pointLoadPaint,
        );

        _drawText(
          canvas,
          'Fy=${node.loadY.toStringAsFixed(0)}',
          Offset(x + 10, y + direction * arrowSize / 2 - 5),
          Colors.orange,
          fontSize: 9,
        );
      }
    }
  }

  /// Наконечник для ВЕРТИКАЛЬНОЙ стрелки
  void _drawArrowHeadVertical(
    Canvas canvas,
    Offset tip,
    int direction,
    Paint paint,
  ) {
    const double size = 6.5;

    canvas.drawPath(
      Path()
        ..moveTo(tip.dx - size / 2, tip.dy)
        ..lineTo(tip.dx + size / 2, tip.dy)
        ..lineTo(tip.dx, tip.dy + direction * size)
        ..close(),
      paint,
    );
  }

  /// Наконечник для ГОРИЗОНТАЛЬНОЙ стрелки
  void _drawArrowHeadHorizontal(
    Canvas canvas,
    Offset tip,
    int direction,
    Paint paint,
  ) {
    const double size = 6.5;

    canvas.drawPath(
      Path()
        ..moveTo(tip.dx - direction * size, tip.dy - size / 2)
        ..lineTo(tip.dx - direction * size, tip.dy + size / 2)
        ..lineTo(tip.dx, tip.dy)
        ..close(),
      paint,
    );
  }

  /// Условия закрепления (опоры)
  void _drawSupports(Canvas canvas) {
    if (model.nodes.isEmpty) return;

    // Draw left support at first node if fixLeft is true
    if (model.fixLeft) {
      final firstNode = model.nodes.first;
      final x = model.xToPixel(firstNode.x);
      final y = model.centerY + firstNode.y * model.scale;
      _drawFixedXSupport(canvas, Offset(x, y));
    }

    // Draw right support at last node if fixRight is true
    if (model.fixRight) {
      final lastNode = model.nodes.last;
      final x = model.xToPixel(lastNode.x);
      final y = model.centerY + lastNode.y * model.scale;
      _drawFixedYSupport(canvas, Offset(x, y));
    }
  }

  /// Опора по X (левая) - ПРИВЯЗАНА К УЗЛУ
  void _drawFixedXSupport(Canvas canvas, Offset center) {
    const double size = 14;
    final paint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 1.5;

    // Вертикальная линия ровно на узле
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );

    // Диагональные линии под 45° (влево-вниз)
    const int lineCount = 5;
    const double spacing = 6.5;
    const double lineLength = 10;

    for (int i = 0; i < lineCount; i++) {
      final yStart = center.dy - size + (i * spacing);
      final xStart = center.dx;

      // Идём влево и вниз
      final xEnd = xStart - lineLength / sqrt(2);
      final yEnd = yStart + lineLength / sqrt(2);

      canvas.drawLine(Offset(xStart, yStart), Offset(xEnd, yEnd), paint);
    }
  }

  /// Опора по Y (правая) - ЗЕРКАЛО левой
  void _drawFixedYSupport(Canvas canvas, Offset center) {
    const double size = 14;
    final paint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 1.5;

    // Вертикальная линия ровно на узле
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );

    // ✅ ИСПРАВЛЕНО: Диагональные линии под 45° (вправо-ВВЕРХ, не вниз!)
    // Зеркало левой: если левая идёт влево-вниз, то правая идёт вправо-ВВЕРХ
    const int lineCount = 5;
    const double spacing = 6.5;
    const double lineLength = 10;

    for (int i = 0; i < lineCount; i++) {
      final yStart = center.dy - size + (i * spacing);
      final xStart = center.dx;

      // Идём вправо и ВВЕРХ (противоположно левой опоре)
      final xEnd = xStart + lineLength / sqrt(2);
      final yEnd = yStart - lineLength / sqrt(2); // ← МИНУС вместо ПЛЮСА!

      canvas.drawLine(Offset(xStart, yStart), Offset(xEnd, yEnd), paint);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    double fontSize = 12,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(VisualizationPainter oldDelegate) {
    return oldDelegate.model != model;
  }
}
