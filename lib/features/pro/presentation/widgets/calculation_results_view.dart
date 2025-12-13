import 'package:flutter/material.dart';
import 'package:saprbar_desktop/features/pro/data/models/calculation_result_model.dart';

class CalculationResultsView extends StatefulWidget {
  final CalculationResultModel result;

  const CalculationResultsView({super.key, required this.result});

  @override
  State<CalculationResultsView> createState() => _CalculationResultsViewState();
}

class _CalculationResultsViewState extends State<CalculationResultsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Узлы'), Tab(text: 'Стержни')],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildNodesTable(), _buildElementsTable()],
          ),
        ),
      ],
    );
  }

  /// Таблица результатов для узлов
  Widget _buildNodesTable() {
    if (widget.result.nodeResults.isEmpty) {
      return const Center(
        child: Text('Нет результатов', style: TextStyle(color: Colors.white70)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8),
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text('ID', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('Δ [м]', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('F [Н]', style: TextStyle(color: Colors.white)),
            ),
          ],
          rows: [
            for (var node in widget.result.nodeResults)
              DataRow(
                cells: [
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${node.nodeId}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          node.displacement.toStringAsFixed(6),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          node.loadX.toStringAsFixed(2),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Таблица результатов для стержней
  Widget _buildElementsTable() {
    if (widget.result.elementResults.isEmpty) {
      return const Center(
        child: Text('Нет результатов', style: TextStyle(color: Colors.white70)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8),
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text('ID', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('N [Н]', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('σ [МПа]', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(label: Text('ε', style: TextStyle(color: Colors.white))),
          ],
          rows: [
            for (var elem in widget.result.elementResults)
              DataRow(
                cells: [
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${elem.elementId}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          elem.internalForce.toStringAsFixed(2),
                          style: TextStyle(
                            color:
                                elem.internalForce >= 0
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          elem.stress.toStringAsFixed(3),
                          style: TextStyle(
                            color:
                                elem.stress.abs() < 100
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          elem.strain.toStringAsFixed(6),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
