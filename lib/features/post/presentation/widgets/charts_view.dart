// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

/// Виджет для интерактивных графиков
/// 
/// В дальнейших итерациях может использоваться:
/// - fl_chart для красивых графиков
/// - charts для более сложных визуализаций
class ChartsView extends StatelessWidget {
  final dynamic diagramData;

  const ChartsView({
    super.key,
    required this.diagramData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'Интерактивные графики',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              'Используйте вкладки выше для просмотра эпюр',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
