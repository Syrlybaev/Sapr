import 'package:flutter/material.dart';

class ProcessorPanel extends StatelessWidget {
  const ProcessorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.grey.shade800,
      child: const Center(
        child: Text('Processor Panel (здесь будут расчёты)', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
