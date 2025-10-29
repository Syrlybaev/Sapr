import 'package:flutter/material.dart';
import 'package:saprbar_desktop/core/router/router.dart';

class SaprBarApp extends StatelessWidget {
  SaprBarApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
      theme: ThemeData.dark(),
    );
  }
}
