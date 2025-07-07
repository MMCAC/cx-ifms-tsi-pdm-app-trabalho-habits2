import 'package:flutter/material.dart';

class CompletedHabitItem extends StatelessWidget {
  final String nome;
  final VoidCallback onRemover;

  const CompletedHabitItem({
    super.key,
    required this.nome,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final greenColor = Theme.of(context).colorScheme.primary;
    final deleteColor = Theme.of(context).colorScheme.error;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: greenColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: greenColor),
        title: Text(
          nome,
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: greenColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: deleteColor),
          onPressed: onRemover,
        ),
      ),
    );
  }
}
