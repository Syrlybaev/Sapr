import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.grey.shade900,
      child: const Center(
        child: Text(
          'Toolbar (здесь будет меню, настройки, файлы)',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
