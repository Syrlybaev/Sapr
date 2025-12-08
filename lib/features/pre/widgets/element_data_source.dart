import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saprbar_desktop/features/pre/bloc/pre_bloc.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:saprbar_desktop/core/models/element_model.dart';
import 'package:saprbar_desktop/core/models/node_model.dart';

/// DataSource для таблицы стержней
class ElementDataSource extends DataGridSource {
  final PreBloc preBloc;
  final List<ElementModel> _elements;
  final List<NodeModel> _nodes;
  final BuildContext context;
  List<DataGridRow> _rows = [];
  String _currentEditValue = '';
  FocusNode? _currentFocusNode;

  List<ElementModel> get elements => List.unmodifiable(_elements);

  ElementDataSource({
    required List<ElementModel> elements,
    required List<NodeModel> nodes,
    required this.preBloc,
    required this.context,
  }) : _elements = List.from(elements),
       _nodes = List.from(nodes) {
    _buildRows();
  }

  void _buildRows() {
    try {
      _rows =
          _elements.map((element) {
            final startNode = _nodes.firstWhere(
              (n) => n.id == element.nodeStartId,
              orElse: () => NodeModel(id: -1, x: 0),
            );
            final endNode = _nodes.firstWhere(
              (n) => n.id == element.nodeEndId,
              orElse: () => NodeModel(id: -1, x: 0),
            );
            final length = (endNode.x - startNode.x).abs();

            return DataGridRow(
              cells: [
                DataGridCell<int>(columnName: 'id', value: element.id),
                DataGridCell<int>(
                  columnName: 'nodeStartId',
                  value: element.nodeStartId,
                ),
                DataGridCell<int>(
                  columnName: 'nodeEndId',
                  value: element.nodeEndId,
                ),
                DataGridCell<double>(columnName: 'length', value: length),
                DataGridCell<double>(columnName: 'E', value: element.E),
                DataGridCell<double>(columnName: 'A', value: element.A),
                DataGridCell<double>(columnName: 'q', value: element.qy),
                DataGridCell<double>(columnName: 'qx', value: element.qx),
                DataGridCell<double>(
                  columnName: 'allowableStress',
                  value: element.allowableStress,
                ),
              ],
            );
          }).toList();
    } catch (e) {
      debugPrint('Error building element rows: $e');
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
    return col == 'E' ||
        col == 'A' ||
        col == 'q' ||
        col == 'qx' ||
        col == 'allowableStress';
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
      keyboardType: TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
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
    if (parsed == null || _currentEditValue.isEmpty) {
      _showError('Введите корректное число');
      return false;
    }

    if (col == 'E' && parsed <= 0) {
      _showError('Модуль упругости E должен быть > 0');
      return false;
    }

    if (col == 'A' && parsed <= 0) {
      _showError('Площадь сечения A должна быть > 0');
      return false;
    }

    // q может быть отрицательным (противоположное направление поперечной нагрузки)
    // Значение 0 допускается (нагрузка отсутствует)

    // qx может быть отрицательным (противоположное направление продольной нагрузки)
    // Значение 0 допускается (нагрузка отсутствует)

    if (col == 'allowableStress' && parsed <= 0) {
      _showError('Допускаемое напряжение должно быть > 0');
      return false;
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

    final int elementId =
        dataGridRow.getCells().firstWhere((c) => c.columnName == 'id').value
            as int;
    final int modelIndex = _elements.indexWhere((e) => e.id == elementId);

    if (modelIndex == -1) return;

    ElementModel element = _elements[modelIndex];

    switch (col) {
      case 'E':
        element = element.copyWith(E: parsed);
        break;
      case 'A':
        element = element.copyWith(A: parsed);
        break;
      case 'q':
        element = element.copyWith(q: parsed);
        break;
      case 'qx':
        element = element.copyWith(qx: parsed);
        break;
      case 'allowableStress':
        element = element.copyWith(allowableStress: parsed);
        break;
    }

    _elements[modelIndex] = element;
    _buildRows();
    notifyListeners();

    preBloc.add(PreSaveEvent(elements: _elements));

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

  void updateData(List<ElementModel> newElements, List<NodeModel> newNodes) {
    _elements.clear();
    _elements.addAll(newElements);
    _nodes.clear();
    _nodes.addAll(newNodes);
    _buildRows();
    notifyListeners();
  }

  @override
  void dispose() {
    _currentFocusNode?.dispose();
    super.dispose();
  }
}
