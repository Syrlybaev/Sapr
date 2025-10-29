import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:saprbar_desktop/features/preprocessor/widgets/widgets.dart';

@RoutePage()
class PreprocessorScreen extends StatelessWidget {
  const PreprocessorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Row(
              children: const [
                LeftSidebar(),
                CenterPanel(),
                Expanded(child: CanvasArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
