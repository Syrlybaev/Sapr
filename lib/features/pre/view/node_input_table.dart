import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:saprbar_desktop/features/pre/bloc/pre_bloc.dart';
import 'package:saprbar_desktop/features/pre/widgets/node_data_source.dart';

class NodeInputTable extends StatefulWidget {
  const NodeInputTable({super.key});

  @override
  State<NodeInputTable> createState() => _NodeInputTableState();
}

class _NodeInputTableState extends State<NodeInputTable> {
  late NodeDataSource _nodeDataSource;

  @override
  void initState() {
    super.initState();
    _initDataSource();
  }

  void _initDataSource() {
    final state = context.read<PreBloc>().state;
    if (state is PreLoadedState) {
      _nodeDataSource = NodeDataSource(
        nodes: List.from(state.project.nodes),
        preBloc: context.read<PreBloc>(),
        context: context,
      );
    } else {
      _nodeDataSource = NodeDataSource(
        nodes: [],
        preBloc: context.read<PreBloc>(),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PreBloc, PreState>(
      listenWhen: (prev, curr) {
        if (prev is PreLoadedState && curr is PreLoadedState) {
          return prev.project.nodes != curr.project.nodes;
        }
        return false;
      },
      listener: (context, state) {
        if (state is PreLoadedState) {
          setState(() {
            _nodeDataSource = NodeDataSource(
              nodes: List.from(state.project.nodes),
              preBloc: context.read<PreBloc>(),
              context: context,
            );
          });
        }
      },
      child: BlocBuilder<PreBloc, PreState>(
        builder: (context, state) {
          if (state is PreLoadedState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOOLBAR (закреплена сверху)
                Container(
                  color: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.greenAccent),
                        tooltip: 'Добавить узел',
                        onPressed: () {
                          context.read<PreBloc>().add(PrePlusEvent());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Удалить последний узел',
                        onPressed: () {
                          context.read<PreBloc>().add(PreDeleteEvent());
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Узлы (${state.project.nodes.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // ТАБЛИЦА УЗЛОВ (прокручивается внутри!)
                Expanded(
                  child: Container(
                    color: Colors.grey.shade900,
                    child: SfDataGrid(
                      source: _nodeDataSource,
                      allowEditing: true,
                      navigationMode: GridNavigationMode.cell,
                      editingGestureType: EditingGestureType.tap,
                      gridLinesVisibility: GridLinesVisibility.both,
                      headerGridLinesVisibility: GridLinesVisibility.both,
                      selectionMode: SelectionMode.single,
                      columnWidthMode: ColumnWidthMode.fill,
                      // ВАЖНО: frozenRowsCount = 1 закрепляет заголовок
                      columns: _buildNodeColumns(),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is PreLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  List<GridColumn> _buildNodeColumns() => [
    GridColumn(
      columnName: 'id',
      allowEditing: false,
      label: _buildHeader('ID'),
      width: 40,
    ),
    GridColumn(columnName: 'x', label: _buildHeader('X'), width: 40),
    GridColumn(
      columnName: 'y',
      allowEditing: false,
      label: _buildHeader('Y'),
      width: 40,
    ),
    GridColumn(columnName: 'loadX', label: _buildHeader('Fx')),
    GridColumn(columnName: 'loadY', label: _buildHeader('Fy')),
  ];

  Widget _buildHeader(String text) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
