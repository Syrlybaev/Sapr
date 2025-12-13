// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saprbar_desktop/features/home/cubit/home_cubit.dart';
import 'package:saprbar_desktop/features/pro/presentation/cubit/processor_cubit.dart';
import 'package:saprbar_desktop/features/pro/presentation/widgets/calculation_results_view.dart';

class ProcessorPanel extends StatefulWidget {
  const ProcessorPanel({super.key});

  @override
  State<ProcessorPanel> createState() => _ProcessorPanelState();
}

class _ProcessorPanelState extends State<ProcessorPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.grey.shade800,
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Процессор',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Кнопка расчёта
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () => _onCalculatePressed(context),
                icon: const Icon(Icons.calculate),
                label: const Text('Рассчитать'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),

          // Содержимое
          Expanded(
            child: BlocBuilder<ProcessorCubit, ProcessorState>(
              builder: (context, state) {
                if (state is ProcessorLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProcessorLoadedState) {
                  return CalculationResultsView(result: state.result);
                }

                if (state is ProcessorErrorState) {
                  return _buildErrorView(state.message);
                }

                return _buildInitialView();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Обработка нажатия на кнопку расчёта
  void _onCalculatePressed(BuildContext context) {
    // Получить HomeCubit из контекста
    final homeCubit = context.read<HomeCubit>();

    // Получить текущий проект
    final currentProject = homeCubit.currentProject;

    // Проверить, что проект загружен
    if (currentProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Проект не загружен')),
      );
      return;
    }

    // Проверить, что есть данные
    if (currentProject.nodes.isEmpty || currentProject.elements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте узлы и стержни')),
      );
      return;
    }

    debugPrint('📊 Узлы в процессоре:');
    for (var node in currentProject.nodes) {
      debugPrint(' Node ${node.id}: loadX=${node.loadX}');
    }

    // Запустить расчёт
    context.read<ProcessorCubit>().calculateStructure(currentProject);
  }

  /// Начальный вид
  Widget _buildInitialView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Нажмите "Рассчитать" для выполнения анализа конструкции',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }

  /// Вид с ошибкой
  Widget _buildErrorView(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
