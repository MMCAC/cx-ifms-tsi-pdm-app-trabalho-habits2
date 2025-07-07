import 'package:flutter/material.dart';

class HabitTitle extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onToggleTheme;

  const HabitTitle({
    super.key,
    required this.title,
    required this.color,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          icon: Icon(Icons.brightness_6),
          onPressed: onToggleTheme,
          tooltip: 'Alternar modo claro/escuro',
        ),
      ],
    );
  }
}
