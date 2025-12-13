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
              Text('Максимум', style: TextStyle(color: Colors.white70, fontSize: 11)),
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
              Text('Минимум', style: TextStyle(color: Colors.white70, fontSize: 11)),
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
              Text('Среднее', style: TextStyle(color: Colors.white70, fontSize: 11)),
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

  /// Canvas для рисования эпюры
  Widget _buildDiagramCanvas() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: DiagramPainter(diagram),
        size: Size.infinite,
      ),
    );
  }

  /// Таблица точек
  Widget _buildPointsTable() {
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
            headingRowColor:
                MaterialStateProperty.all(Colors.grey.shade800),
            columns: [
              DataColumn(
                label: Text('x [м]', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('${diagram.name} [${diagram.unit}]',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
            rows: [
              for (var point in diagram.points)
                DataRow(cells: [
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
                        color: point.value >= 0
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                    ),
                  ),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter для рисования эпюры
class DiagramPainter extends CustomPainter {
  final DiagramModel diagram;

  DiagramPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    if (diagram.points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    const padding = 40.0;
    final graphWidth = size.width - 2 * padding;
    final graphHeight = size.height - 2 * padding;

    // Находим min/max x и y для масштабирования
    final minX = diagram.points.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final maxX = diagram.points.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    final rangeX = maxX - minX;

    final minY = diagram.minValue;
    final maxY = diagram.maxValue;
    final rangeY = maxY - minY;

    // Функция для преобразования координат
    double transformX(double x) {
      return padding + (x - minX) / rangeX * graphWidth;
    }

    double transformY(double y) {
      return size.height - padding - (y - minY) / rangeY * graphHeight;
    }

    // Рисуем оси
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

    // Рисуем эпюру
    for (int i = 0; i < diagram.points.length - 1; i++) {
      final p1 = diagram.points[i];
      final p2 = diagram.points[i + 1];

      final linePaint = Paint()
        ..color = p1.value >= 0 ? Colors.greenAccent : Colors.redAccent
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(transformX(p1.x), transformY(p1.value)),
        Offset(transformX(p2.x), transformY(p2.value)),
        linePaint,
      );
    }

    // Рисуем точки
    for (var point in diagram.points) {
      canvas.drawCircle(
        Offset(transformX(point.x), transformY(point.value)),
        4,
        Paint()..color = Colors.blueAccent,
      );
    }
  }

  @override
  bool shouldRepaint(DiagramPainter oldDelegate) => false;
}
