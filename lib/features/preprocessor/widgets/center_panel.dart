import 'package:flutter/material.dart';

class CenterPanel extends StatelessWidget {
  const CenterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.grey.shade800,
      child: const Center(
        child: Text(
          'Зона данных (ввод, таблицы, расчёты)',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
