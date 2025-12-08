import 'package:flutter/material.dart';
import 'package:saprbar_desktop/features/home/widgets/center_panel.dart';
import 'package:saprbar_desktop/features/home/widgets/widgets.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            const TopBar(),
            Expanded(
              child: Row(
                children: [
                  const LeftSidebar(),
                  CenterPanel(),
                  const Expanded(child: CanvasArea()),
                ],
              ),
            ),
          ],
        ),
      );
  }

}