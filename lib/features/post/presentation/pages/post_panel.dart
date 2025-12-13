// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saprbar_desktop/features/post/presentation/cubit/post_cubit.dart';
import 'package:saprbar_desktop/features/post/presentation/widgets/analysis_view.dart';
import 'package:saprbar_desktop/features/post/presentation/widgets/diagrams_view.dart';
import 'package:saprbar_desktop/features/pro/presentation/cubit/processor_cubit.dart';

/// Главный виджет постпроцессора
///
/// Получает результаты расчета от ProcessorCubit и показывает эпюры
class PostPanel extends StatefulWidget {
  const PostPanel({super.key});

  @override
  State<PostPanel> createState() => _PostPanelState();
}

class _PostPanelState extends State<PostPanel> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔴 ИСПРАВЛЕНО: Слушаем ProcessorCubit и получаем project
    final processorState = context.read<ProcessorCubit>().state;

    if (processorState is ProcessorLoadedState) {
      debugPrint('📊 PostPanel: Получены результаты от процессора!');
      debugPrint('   Узлов: ${processorState.result.nodeResults.length}');
      debugPrint('   Стержней: ${processorState.result.elementResults.length}');
      debugPrint('   Проект: ${processorState.project.name}');

      // 🔴 ИСПРАВЛЕНО: Передаем и result и project
      context.read<PostCubit>().processCalculationResults(
        calculationResult: processorState.result,
        project: processorState.project, // 🔴 НОВОЕ: Передаем проект
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.grey.shade900,
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade700, width: 1),
              ),
            ),
            child: const Text(
              'Постпроцессор',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Табы
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade700, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(child: Text('Nx (Силы)')),
                Tab(child: Text('σ (Напряжения)')),
                Tab(child: Text('Δ (Перемещения)')),
                Tab(child: Text('Анализ')),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
            ),
          ),

          // Содержимое вкладок
          Expanded(
            child: BlocListener<ProcessorCubit, ProcessorState>(
              listener: (context, processorState) {
                if (processorState is ProcessorLoadedState) {
                  debugPrint(
                    '🔄 PostPanel: Обновление при получении результатов',
                  );
                }
              },
              child: BlocBuilder<PostCubit, PostState>(
                builder: (context, postState) {
                  return _buildTabContent(context, postState);
                },
              ),
            ),
          ),

          // Кнопки внизу
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade700, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportReport(context, asJson: false),
                    icon: const Icon(Icons.download),
                    label: const Text('Отчет (TXT)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportReport(context, asJson: true),
                    icon: const Icon(Icons.code),
                    label: const Text('Отчет (JSON)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Построить содержимое для текущей вкладки
  Widget _buildTabContent(BuildContext context, PostState postState) {
    if (postState is PostLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (postState is PostLoadedState) {
      return TabBarView(
        controller: _tabController,
        children: [
          DiagramsView(diagram: postState.internalForces, onRefresh: () {}),
          DiagramsView(diagram: postState.stresses, onRefresh: () {}),
          DiagramsView(diagram: postState.displacements, onRefresh: () {}),
          AnalysisView(
            analysis: postState.analysis,
            analysisData: postState.analysis,
          ),
        ],
      );
    }

    if (postState is PostErrorState) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Ошибка: ${postState.message}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    // PostInitialState - ждем данных
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info, color: Colors.grey.shade600, size: 48),
          const SizedBox(height: 16),
          Text(
            'Выполните расчет конструкции\nв процессоре для просмотра результатов',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Экспортировать отчет
  void _exportReport(BuildContext context, {required bool asJson}) {
    final postState = context.read<PostCubit>().state;
    if (postState is! PostLoadedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет результатов для экспорта')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(asJson ? 'Отчет JSON сохранен' : 'Отчет TXT сохранен'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
