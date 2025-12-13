import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:saprbar_desktop/core/models/node_model.dart';
import 'package:saprbar_desktop/features/pre/bloc/pre_bloc.dart';

/// DataSource для таблицы УЗЛОВ (не элементов!)
class NodeDataSource extends DataGridSource {
  final PreBloc preBloc;
  final List<NodeModel> _nodes;
  final BuildContext context;
  List<DataGridRow> _rows = [];
  String _currentEditValue = '';
  FocusNode? _currentFocusNode;

  List<NodeModel> get nodes => List.unmodifiable(_nodes);

  NodeDataSource({
    required List<NodeModel> nodes,
    required this.preBloc,
    required this.context,
  }) : _nodes = List.from(nodes) {
    _buildRows();
  }

  void _buildRows() {
    try {
      _rows =
          _nodes.map((node) {
            return DataGridRow(
              cells: [
                DataGridCell<int>(columnName: 'id', value: node.id),
                DataGridCell<double>(columnName: 'x', value: node.x),
                // DataGridCell<double>(columnName: 'y', value: node.y),
                DataGridCell<double>(columnName: 'loadX', value: node.loadX),
                // DataGridCell<double>(columnName: 'loadY', value: node.loadY),
              ],
            );
          }).toList();
    } catch (e) {
      debugPrint('Error building node rows: $e');
      _rows = [];
    }
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Colors.grey.shade800,
      cells:
          row.getCells().map((cell) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Text(
                _formatValue(cell.columnName, cell.value),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            );
          }).toList(),
    );
  }

  String _formatValue(String columnName, dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  @override
  bool onCellBeginEdit(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) {
    final col = column.columnName;
    return col != 'id' && col != 'y';
  }

  @override
  Widget? buildEditWidget(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    final col = column.columnName;

    final oldValue =
        dataGridRow
            .getCells()
            .firstWhere((c) => c.columnName == col)
            .value
            .toString();

    final controller = TextEditingController(text: oldValue);
    _currentEditValue = oldValue;
    _currentFocusNode = FocusNode();

    _currentFocusNode!.addListener(() {
      if (!_currentFocusNode!.hasFocus) {
        submitCell();
      }
    });

    return TextField(
      controller: controller,
      focusNode: _currentFocusNode,
      autofocus: true,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.all(8),
      ),
      onChanged: (text) {
        _currentEditValue = text;
      },
      onSubmitted: (text) {
        _currentEditValue = text;
        submitCell();
      },
    );
  }

  @override
  Future<bool> canSubmitCell(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) async {
    final col = column.columnName;

    final parsed = double.tryParse(_currentEditValue);
    if (parsed == null) {
      _showError('Введите корректное число');
      return false;
    }

    if (col == 'x') {
      if (parsed < 0) {
        _showError(' дината X не может быть отрицательной');
        return false;
      }

      final int editedId =
          dataGridRow.getCells().firstWhere((c) => c.columnName == 'id').value
              as int;
      final int currentIndex = _nodes.indexWhere((n) => n.id == editedId);

      if (currentIndex == -1) return false;

      // if (currentIndex > 0) {
      //   final double prevX = _nodes[currentIndex - 1].x;
      //   if (parsed < prevX) {
      //     _showError(
      //       'Координата X должна быть >= предыдущего узла (${prevX.toStringAsFixed(2)})',
      //     );
      //     return false;
      //   }
      // }

      // if (currentIndex < _nodes.length - 1) {
      //   final double nextX = _nodes[currentIndex + 1].x;
      //   if (parsed > nextX) {
      //     _showError(
      //       'Координата X должна быть <= следующего узла (${nextX.toStringAsFixed(2)})',
      //     );
      //     return false;
      //   }
      // }
    }

    return true;
  }

  @override
  Future<void> onCellSubmit(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) async {
    _currentFocusNode?.dispose();
    _currentFocusNode = null;

    final col = column.columnName;
    final parsed = double.parse(_currentEditValue);

    final int editedId =
        dataGridRow.getCells().firstWhere((c) => c.columnName == 'id').value
            as int;
    final int modelIndex = _nodes.indexWhere((n) => n.id == editedId);

    if (modelIndex == -1) return;

    NodeModel node = _nodes[modelIndex];
    switch (col) {
      case 'x':
        node = node.copyWith(x: parsed);
        break;
      case 'loadX':
        node = node.copyWith(loadX: parsed);
        break;
      // case 'loadY':
      //   node = node.copyWith(loadY: parsed);
      //   break;
    }

    _nodes[modelIndex] = node;
    _nodes.sort((a, b) => a.x.compareTo(b.x));
    _buildRows();
    notifyListeners();

    // Сохраняем только узлы
    preBloc.add(PreSaveEvent(nodes: _nodes));

    _currentEditValue = '';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _currentFocusNode?.dispose();
    super.dispose();
  }
}
