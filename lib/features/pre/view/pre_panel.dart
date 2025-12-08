import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saprbar_desktop/features/pre/bloc/pre_bloc.dart';
import 'package:saprbar_desktop/features/pre/view/node_input_table.dart';
import 'package:saprbar_desktop/features/pre/view/element_input_table.dart';

class PrePanel extends StatelessWidget {
  const PrePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.grey.shade800,
      child: BlocBuilder<PreBloc, PreState>(
        builder: (context, state) {
          // Если проект не загружен → пустая панель
          if (state is PreInitialState) {
            return Center(
              child: Text(
                'Проект не выбран',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            );
          }

          // Если идёт загрузка → спиннер
          if (state is PreLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          // Если ошибка → показываем её
          if (state is PreFailureState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ошибка: ${state.message}',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () {
                    context.read<PreBloc>().add(PreLoadEvent());
                  },
                  child: Text('Попробовать снова'),
                ),
              ],
            );
          }

          // Если проект загружен → показываем таблицы
          if (state is PreLoadedState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ПАНЕЛЬ УПРАВЛЕНИЯ ОПОРАМИ
                Container(
                  color: Colors.grey.shade900,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Граничные условия',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<PreBloc>().add(
                                  PreSetSupportsEvent(
                                    supportMode: SupportMode.none,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Нет опор'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                backgroundColor: Colors.grey.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<PreBloc>().add(
                                  PreSetSupportsEvent(
                                    supportMode: SupportMode.left,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Левая'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<PreBloc>().add(
                                  PreSetSupportsEvent(
                                    supportMode: SupportMode.right,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('Правая'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<PreBloc>().add(
                                  PreSetSupportsEvent(
                                    supportMode: SupportMode.both,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.unfold_less, size: 16),
                              label: const Text('Обе'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ТАБЛИЦА УЗЛОВ (скролится внутри себя)
                Expanded(child: NodeInputTable()),

                // РАЗДЕЛИТЕЛЬ
                Divider(color: Colors.grey.shade700, height: 1, thickness: 1),

                // ТАБЛИЦА СТЕРЖНЕЙ (скролится внутри себя)
                Expanded(child: ElementInputTable()),
              ],
            );
          }

          // Fallback
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
