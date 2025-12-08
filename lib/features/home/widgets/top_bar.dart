import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saprbar_desktop/features/home/bloc/file_bloc.dart';
import 'package:saprbar_desktop/features/pre/bloc/pre_bloc.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          /// МЕНЮ "Файл"
          PopupMenuButton<String>(
            tooltip: "Файл",
            color: Colors.grey.shade800,
            onSelected: (value) {
              if (value == 'new') {
                _createProjectDialog(context);
              } else if (value == 'load') {
                _loadProjectDialog(context);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'new',
                    child: Text("Новый проект"),
                  ),
                  const PopupMenuItem(
                    value: 'load',
                    child: Text("Открыть проект"),
                  ),
                ],
            child: const Text(
              "Файл",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          const SizedBox(width: 20),

          /// Отображение текущего проекта
          BlocBuilder<FileBloc, FileState>(
            builder: (context, state) {
              if (state is FileLoadedState) {
                return Text(
                  "Проект: ${state.name}",
                  style: const TextStyle(color: Colors.white70),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _createProjectDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Создать новый проект"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Название проекта"),
            ),
            actions: [
              TextButton(
                child: const Text("Отмена"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Создать"),
                onPressed: () {
                  // ВАЖНО: Сначала создаём проект через FileBloc
                  context.read<FileBloc>().add(
                    FileCreateEvent(name: controller.text.trim()),
                  );

                  // Потом загружаем через PreBloc
                  // Future.delayed гарантирует что FileBloc завершит первым
                  Future.delayed(const Duration(milliseconds: 50), () {
                    context.read<PreBloc>().add(PreLoadEvent());
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _loadProjectDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Открыть проект"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Название проекта"),
            ),
            actions: [
              TextButton(
                child: const Text("Отмена"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Открыть"),
                onPressed: () {
                  // ВАЖНО: Сначала загружаем проект через FileBloc
                  context.read<FileBloc>().add(
                    FileLoadEvent(name: controller.text.trim()),
                  );

                  // Потом загружаем через PreBloc
                  // Future.delayed гарантирует что FileBloc завершит первым
                  Future.delayed(const Duration(milliseconds: 50), () {
                    context.read<PreBloc>().add(PreLoadEvent());
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }
}
