import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      color: Colors.grey.shade800,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.build_circle, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
