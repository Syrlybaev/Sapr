import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saprbar_desktop/features/home/cubit/home_cubit.dart';
import 'package:saprbar_desktop/features/post/view/postprocessor_panel.dart';
import 'package:saprbar_desktop/features/pre/view/pre_panel.dart';
import 'package:saprbar_desktop/features/pro/view/processor_panel.dart';

class CenterPanel extends StatelessWidget {
  const CenterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        switch (state) {
          case HomeState.preprocessor:
            return const PrePanel();
          case HomeState.processor:
            return const ProcessorPanel();
          case HomeState.postprocessor:
            return const PostprocessorPanel();
        }
      },
    );
  }
}
