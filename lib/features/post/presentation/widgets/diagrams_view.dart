// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

import 'package:saprbar_desktop/features/post/data/models/diagram_model.dart';

/// Виджет для отрисовки эпюр
class DiagramsView extends StatelessWidget {
  final DiagramModel diagram;
  final VoidCallback onRefresh;

  const DiagramsView({
    super.key,
    required this.diagram,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (diagram.points.isEmpty) {
      return Center(
        child: Text(
          'Нет данных для эпюры ${diagram.name}',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Эпюра ${diagram.name} [${diagram.unit}]',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue),
                  onPressed: onRefresh,
                ),
              ],
            ),
            SizedBox(height: 16),

            // Статистика
            _buildStatistics(),
            SizedBox(height: 16),

            // График эпюры
            _buildDiagramCanvas(),
            SizedBox(height: 16),

            // Таблица точек
            _buildPointsTable(),
          ],
        ),
      ),
    );
  }

  /// Статистика
  Widget _buildStatistics() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Максимум',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                diagram.maxValue.toStringAsFixed(3),
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Минимум',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                diagram.minValue.toStringAsFixed(3),
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Среднее',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                diagram.averageValue.toStringAsFixed(3),
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Canvas для рисования эпюры (ИСПРАВЛЕНО)
  Widget _buildDiagramCanvas() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(painter: DiagramPainter(diagram), size: Size.infinite),
    );
  }

  /// Таблица точек
  Widget _buildPointsTable() {
    // final diagramPoints = diagram.points;
    // final nodePoints = diagramPoints.where((p) => p.isNode).toList();
    final nodePoints =
        diagram.points
            .where((p) => p.isNode)
            .fold<Map<double, DiagramPoint>>({}, (map, p) {
              // ключ — координата x, округляем чтобы не словить 0.999999/1.0
              final key = double.parse(p.x.toStringAsFixed(6));
              map.putIfAbsent(key, () => p); // первый встретившийся оставляем
              return map;
            })
            .values
            .toList()
          ..sort((a, b) => a.x.compareTo(b.x));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Точки эпюры:',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade800),
            columns: [
              DataColumn(
                label: Text('x [м]', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text(
                  '${diagram.name} [${diagram.unit}]',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],

            rows: [
              for (var point in nodePoints)
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        point.x.toStringAsFixed(2),
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    DataCell(
                      Text(
                        point.value.toStringAsFixed(6),
                        style: TextStyle(
                          color:
                              point.value >= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter для рисования эпюры (✅ ПОЛНОСТЬЮ ИСПРАВЛЕНО)
class DiagramPainter extends CustomPainter {
  final DiagramModel diagram;

  DiagramPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    if (diagram.points.isEmpty) return;

    const padding = 50.0;
    final graphWidth = size.width - 2 * padding;
    final graphHeight = size.height - 2 * padding;

    // Находим min/max для масштабирования
    final minX = diagram.points.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final maxX = diagram.points.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    var rangeX = maxX - minX;

    // ✅ ИСПРАВЛЕНО: Защита от деления на 0
    if (rangeX <= 0) rangeX = 1.0;

    final minY = diagram.minValue;
    final maxY = diagram.maxValue;
    var rangeY = maxY - minY;

    // ✅ ИСПРАВЛЕНО: Защита от деления на 0
    if (rangeY <= 0) rangeY = 1.0;

    // Функция для преобразования координат
    double transformX(double x) => padding + (x - minX) / rangeX * graphWidth;

    double transformY(double y) =>
        size.height - padding - (y - minY) / rangeY * graphHeight;

    // Рисуем оси
    final axisPaint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );

    // ✅ ИСПРАВЛЕНО: Нулевая линия БЕЗ strokeDashPattern
    if (minY <= 0 && maxY >= 0) {
      final zeroLinePaint =
          Paint()
            ..color = Colors.grey.withOpacity(0.4)
            ..strokeWidth = 1.0;

      // ✅ РИСУЕМ ПУНКТИРНУЮ ЛИНИЮ МАНУАЛЬНО
      final zeroY = transformY(0);
      final dashLength = 8.0;
      final dashGap = 4.0;
      var currentX = padding;

      while (currentX < size.width - padding) {
        final nextDash = currentX + dashLength;
        if (nextDash > size.width - padding) {
          canvas.drawLine(
            Offset(currentX, zeroY),
            Offset(size.width - padding, zeroY),
            zeroLinePaint,
          );
        } else {
          canvas.drawLine(
            Offset(currentX, zeroY),
            Offset(nextDash, zeroY),
            zeroLinePaint,
          );
        }
        currentX += dashLength + dashGap;
      }
    }

    // Рисуем эпюру линиями
    for (int i = 0; i < diagram.points.length - 1; i++) {
      final p1 = diagram.points[i];
      final p2 = diagram.points[i + 1];

      final linePaint =
          Paint()
            ..color = _getColor(p1.value)
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(transformX(p1.x), transformY(p1.value)),
        Offset(transformX(p2.x), transformY(p2.value)),
        linePaint,
      );
    }

    // Рисуем точки
    for (var point in diagram.points) {
      final bool isNodePoint =
          (diagram.points.first.x == point.x) ||
          (diagram.points.last.x ==
              point.x); // или сравниваешь point.x с узловыми x

      if (!isNodePoint) {
        // не рисуем, только линия остаётся
        continue;
      }

      canvas.drawCircle(
        Offset(transformX(point.x), transformY(point.value)),
        5.0,
        Paint()
          ..color = _getColor(point.value).withOpacity(0.3)
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        Offset(transformX(point.x), transformY(point.value)),
        3.0,
        Paint()
          ..color = Colors.blueAccent
          ..strokeWidth = 2,
      );
    }

    // Рисуем оси с метками
    _drawAxisLabels(
      canvas,
      size,
      padding,
      minX,
      maxX,
      minY,
      maxY,
      transformX,
      transformY,
    );
  }

  Color _getColor(double value) {
    if (value >= 0) {
      return Colors.greenAccent;
    } else {
      return Colors.redAccent;
    }
  }

  void _drawAxisLabels(
    Canvas canvas,
    Size size,
    double padding,
    double minX,
    double maxX,
    double minY,
    double maxY,
    double Function(double) transformX,
    double Function(double) transformY,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const int tickCount = 5;

    // Метки оси X
    for (int i = 0; i <= tickCount; i++) {
      final x = minX + (maxX - minX) * (i / tickCount);
      final xPixel = transformX(x);

      final text = x.toStringAsFixed(1);
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: Colors.white70, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xPixel - textPainter.width / 2, size.height - padding + 15),
      );
    }

    // Метки оси Y
    for (int i = 0; i <= tickCount; i++) {
      final y = minY + (maxY - minY) * (i / tickCount);
      final yPixel = transformY(y);

      final text = y.toStringAsFixed(2);
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: Colors.white70, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          padding - textPainter.width - 10,
          yPixel - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(DiagramPainter oldDelegate) => true;
}
