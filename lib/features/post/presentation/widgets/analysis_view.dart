import 'package:flutter/material.dart';
import 'package:saprbar_desktop/features/post/domain/entities/stress_analysis.dart';

/// Виджет для анализа прочности
class AnalysisView extends StatelessWidget {
  final List<ElementStressAnalysis> analysisData;

  const AnalysisView({
    super.key,
    required this.analysisData, required analysis,
  });

  @override
  Widget build(BuildContext context) {
    if (analysisData.isEmpty) {
      return Center(
        child: Text(
          'Нет данных для анализа',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final passedCount = analysisData.where((e) => e.isPassed).length;
    final failedCount = analysisData.where((e) => !e.isPassed).length;
    final minSafetyFactor = analysisData
        .map((e) => e.safetyFactor)
        .reduce((a, b) => a < b ? a : b);
    final isConstructionSafe = analysisData.every((e) => e.isPassed);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              'Анализ прочности конструкции',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Карточка с общей информацией
            _buildSummaryCard(
              passedCount,
              failedCount,
              minSafetyFactor,
              isConstructionSafe,
            ),
            SizedBox(height: 16),

            // Таблица анализа
            _buildAnalysisTable(),
          ],
        ),
      ),
    );
  }

  /// Карточка с общей информацией
  Widget _buildSummaryCard(
    int passedCount,
    int failedCount,
    double minSafetyFactor,
    bool isConstructionSafe,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConstructionSafe ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статус
          Row(
            children: [
              Icon(
                isConstructionSafe ? Icons.check_circle : Icons.error,
                color: isConstructionSafe ? Colors.green : Colors.red,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                isConstructionSafe
                    ? '✓ ПРОЧНОСТЬ ОБЕСПЕЧЕНА'
                    : '✗ ТРЕБУЕТСЯ УСИЛЕНИЕ',
                style: TextStyle(
                  color: isConstructionSafe ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Статистика
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildStatItem(
                'Пройдено',
                '$passedCount/${passedCount + failedCount}',
                Colors.greenAccent,
              ),
              _buildStatItem(
                'Не пройдено',
                failedCount.toString(),
                failedCount > 0 ? Colors.redAccent : Colors.grey,
              ),
              _buildStatItem(
                'Мин. коэфф. запаса',
                minSafetyFactor.toStringAsFixed(3),
                minSafetyFactor > 1.0 ? Colors.blueAccent : Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Элемент статистики
  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Таблица анализа
  Widget _buildAnalysisTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Результаты по стержням:',
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
                label: Text('ID', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label:
                    Text('σ (МПа)', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('[σ] (МПа)',
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Коэфф.',
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label:
                    Text('Статус', style: TextStyle(color: Colors.white)),
              ),
            ],
            rows: [
              for (var analysis in analysisData)
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '${analysis.elementId}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    DataCell(
                      Text(
                        analysis.stress.toStringAsFixed(3),
                        style: TextStyle(
                          color: analysis.stress >= 0
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        analysis.allowableStress.toStringAsFixed(2),
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    DataCell(
                      Text(
                        analysis.safetyFactor.toStringAsFixed(3),
                        style: TextStyle(
                          color: analysis.safetyFactor > 2.0
                              ? Colors.greenAccent
                              : analysis.safetyFactor > 1.0
                                  ? Colors.orangeAccent
                                  : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: analysis.isPassed
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: analysis.isPassed
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Text(
                          analysis.status,
                          style: TextStyle(
                            color: analysis.isPassed
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
