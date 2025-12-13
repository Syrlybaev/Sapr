// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

/// Виджет для просмотра отчета
/// 
/// Отображает сгенерированный текстовый отчет
class ReportView extends StatelessWidget {
  final String reportContent;
  final VoidCallback onExport;

  const ReportView({
    super.key,
    required this.reportContent,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Кнопка экспорта
        Container(
          padding: EdgeInsets.all(8),
          child: ElevatedButton.icon(
            onPressed: onExport,
            icon: Icon(Icons.download),
            label: Text('Экспортировать'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        
        // Содержимое отчета
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: SelectableText(
              reportContent,
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
