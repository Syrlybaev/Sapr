import 'package:flutter/material.dart';

class PostprocessorPanel extends StatelessWidget {
  const PostprocessorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.grey.shade800,
      child: const Center(
        child: Text('Postprocessor Panel (результаты и эпюры)', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
