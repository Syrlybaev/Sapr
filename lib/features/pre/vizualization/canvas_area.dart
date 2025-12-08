import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saprbar_desktop/features/pre/bloc/pre_bloc.dart';
import 'package:saprbar_desktop/features/pre/vizualization/visualization_model.dart';
import 'package:saprbar_desktop/features/pre/vizualization/visualization_painter.dart';

class CanvasArea extends StatefulWidget {
  const CanvasArea({super.key});

  @override
  State<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> {
  late VisualizationModel _visualizationModel;
  double _scale = 50.0;
  Offset _offset = const Offset(0, 0);
  bool _initialFitDone = false;

  @override
  void initState() {
    super.initState();
    _visualizationModel = VisualizationModel(
      nodes: [],
      elements: [],
      scale: _scale,
      offset: _offset,
    );
  }

  /// Рассчитываем оптимальный масштаб и смещение
  void _fitToView(Size canvasSize) {
    final state = context.read<PreBloc>().state;
    if (state is! PreLoadedState || state.project.nodes.isEmpty) {
      return;
    }

    final (xMin, xMax) = (
      state.project.nodes.map((n) => n.x).reduce((a, b) => a < b ? a : b),
      state.project.nodes.map((n) => n.x).reduce((a, b) => a > b ? a : b),
    );

    final xRange = xMax - xMin;

    // Если все узлы в одной точке
    if (xRange <= 0) {
      setState(() {
        _scale = 50.0;
        _offset = Offset(canvasSize.width / 2 - 50, canvasSize.height / 2 - 40);
        _updateVisualizationModel(state);
      });
      return;
    }

    // Рассчитываем масштаб так, чтобы все поместилось с отступом
    final availableWidth = canvasSize.width - 100;
    final newScale = availableWidth / xRange;

    // Рассчитываем смещение, чтобы конструкция была по центру
    final totalPixelWidth = xRange * newScale;
    final leftMargin = (canvasSize.width - totalPixelWidth) / 2;

    setState(() {
      _scale = newScale.clamp(5.0, 300.0);
      _offset = Offset(leftMargin - xMin * _scale, canvasSize.height / 2 - 40);
      _updateVisualizationModel(state);
    });
  }

  void _updateVisualizationModel(PreLoadedState state) {
    _visualizationModel = VisualizationModel(
      nodes: state.project.nodes,
      elements: state.project.elements,
      fixLeft: state.project.fixLeft, // ← NEW
      fixRight: state.project.fixRight, // ← NEW
      scale: _scale,
      offset: _offset,
      nodeRadius: 3.5,
      distributedLoadArrowHeight: 18.0,
      distributedLoadArrowCount: 4,
      maxSectionHeightPixels: 60.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PreBloc, PreState>(
      listenWhen: (prev, curr) {
        // Перерисовываем при любом изменении проекта
        if (prev is PreLoadedState && curr is PreLoadedState) {
          return prev.project.nodes.length != curr.project.nodes.length ||
              prev.project != curr.project;
        }
        return curr is PreLoadedState;
      },
      listener: (context, state) {
        if (state is PreLoadedState) {
          setState(() {
            _updateVisualizationModel(state);
            // ✅ Пересчитываем масштаб при добавлении/удалении узлов
            final constraints = context.findRenderObject() as RenderBox?;
            if (constraints != null) {
              _fitToView(Size(constraints.size.width, constraints.size.height));
            }
          });
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Первый раз при загрузке
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_initialFitDone &&
                context.read<PreBloc>().state is PreLoadedState) {
              _initialFitDone = true;
              _fitToView(Size(constraints.maxWidth, constraints.maxHeight));
            }
          });

          return Container(
            color: Colors.grey.shade800,
            child: Stack(
              children: [
                // Холст
                CustomPaint(
                  painter: VisualizationPainter(_visualizationModel),
                  size: Size.infinite,
                ),

                // Кнопка "Fit to view" (вписать в окно)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    onPressed: () {
                      _fitToView(
                        Size(constraints.maxWidth, constraints.maxHeight),
                      );
                    },
                    tooltip: 'Вписать конструкцию в окно',
                    child: const Icon(Icons.zoom_out_map),
                  ),
                ),

                // Информация по масштабу
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Масштаб: ${_scale.toStringAsFixed(1)} px/ед',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
