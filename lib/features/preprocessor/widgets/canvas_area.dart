import 'package:flutter/material.dart';

class CanvasArea extends StatelessWidget {
  const CanvasArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade700,
      child: const Center(
        child: Text(
          'Canvas Area (визуализация конструкции)',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
