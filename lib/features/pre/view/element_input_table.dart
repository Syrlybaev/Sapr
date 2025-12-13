import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:saprbar_desktop/features/pre/bloc/pre_bloc.dart';
import 'package:saprbar_desktop/features/pre/widgets/element_data_source.dart';

class ElementInputTable extends StatefulWidget {
  const ElementInputTable({super.key});

  @override
  State<ElementInputTable> createState() => _ElementInputTableState();
}

class _ElementInputTableState extends State<ElementInputTable> {
  late ElementDataSource _elementDataSource;

  @override
  void initState() {
    super.initState();
    _initDataSource();
  }

  void _initDataSource() {
    final state = context.read<PreBloc>().state;
    if (state is PreLoadedState) {
      _elementDataSource = ElementDataSource(
        elements: List.from(state.project.elements),
        nodes: List.from(state.project.nodes),
        preBloc: context.read<PreBloc>(),
        context: context,
      );
    } else {
      _elementDataSource = ElementDataSource(
        elements: [],
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
          return prev.project.elements != curr.project.elements ||
              prev.project.nodes != curr.project.nodes;
        }
        return false;
      },
      listener: (context, state) {
        if (state is PreLoadedState) {
          setState(() {
            _elementDataSource = ElementDataSource(
              elements: List.from(state.project.elements),
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
                // ЗАГОЛОВОК (закреплена сверху)
                Container(
                  color: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Text(
                    'Стержни (${state.project.elements.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ТАБЛИЦА СТЕРЖНЕЙ (прокручивается внутри!)
                Expanded(
                  child: Container(
                    color: Colors.grey.shade900,
                    child:
                        _elementDataSource.rows.isEmpty
                            ? Center(
                              child: Text(
                                'Добавьте узлы для создания стержней',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            )
                            : SfDataGrid(
                              source: _elementDataSource,
                              allowEditing: true,
                              navigationMode: GridNavigationMode.cell,
                              editingGestureType: EditingGestureType.tap,
                              gridLinesVisibility: GridLinesVisibility.both,
                              headerGridLinesVisibility:
                                  GridLinesVisibility.both,
                              selectionMode: SelectionMode.single,
                              columnWidthMode: ColumnWidthMode.fill,
                              columns: _buildElementColumns(),
                            ),
                  ),
                ),
              ],
            );
          } else if (state is PreLoadingState) {
            return const SizedBox.shrink();
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  List<GridColumn> _buildElementColumns() => [
    GridColumn(
      columnName: 'id',
      allowEditing: false,
      label: _buildHeader('ID'),
      width: 30,
    ),
    // GridColumn(
    //   columnName: 'nodeStartId',
    //   allowEditing: false,
    //   label: _buildHeader('NodeId'),
    //   width: 40,
    // ),
    // GridColumn(
    //   columnName: 'nodeEndId',
    //   allowEditing: false,
    //   label: _buildHeader('NodeId'),
    //   width: 40,
    // ),
    GridColumn(columnName: 'length', label: _buildHeader('L'), width: 50),
    GridColumn(columnName: 'E', label: _buildHeader('E')),
    GridColumn(columnName: 'A', label: _buildHeader('A')),
    // GridColumn(columnName: 'q', label: _buildHeader('qy')),
    GridColumn(columnName: 'qx', label: _buildHeader('qx ')),
    GridColumn(columnName: 'allowableStress', label: _buildHeader('[σ]')),
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
