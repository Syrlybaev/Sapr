import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saprbar_desktop/features/home/cubit/home_cubit.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final current = context.watch<HomeCubit>().state;

    return Container(
      width: 40,
      color: Colors.grey.shade800,
      child: Column(
        children: [
          const SizedBox(height: 5),
          _buildButton(
            context,
            Icons.build_circle,
            HomeState.preprocessor,
            current,
            cubit,
          ),
          _buildButton(
            context,
            Icons.calculate,
            HomeState.processor,
            current,
            cubit,
          ),
          _buildButton(
            context,
            Icons.analytics,
            HomeState.postprocessor,
            current,
            cubit,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    IconData icon,
    HomeState mode,
    HomeState current,
    HomeCubit cubit,
  ) {
    final selected = mode == current;
    return GestureDetector(
      onTap: () => cubit.changeMode(mode),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: selected ? Colors.white : Colors.white30),
      ),
    );
  }
}
