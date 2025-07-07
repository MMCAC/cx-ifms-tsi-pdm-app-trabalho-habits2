import 'package:flutter/material.dart';

class HabitItem extends StatelessWidget {
  final String nome;
  final bool concluido;
  final VoidCallback onConcluir;
  final VoidCallback onEditar;
  final VoidCallback? onRemover;

  const HabitItem({
    super.key,
    required this.nome,
    required this.concluido,
    required this.onConcluir,
    required this.onEditar,
    this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = concluido
        ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6)
        : Theme.of(context).textTheme.bodyMedium!.color;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Checkbox(
          value: concluido,
          onChanged: (val) {
            if (val == true) onConcluir();
          },
        ),
        title: Text(
          nome,
          style: TextStyle(
            decoration: concluido ? TextDecoration.lineThrough : null,
            fontSize: 16,
            color: textColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEditar,
            ),
            if (onRemover != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemover,
              ),
          ],
        ),
      ),
    );
  }
}
