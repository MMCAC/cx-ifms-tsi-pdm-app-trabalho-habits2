import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/SettingsController.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onFormSaved;

  const AppDrawer({super.key, this.onFormSaved});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>().settings;

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: settings.color),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(settings.icon, color: settings.color),
                        radius: 30,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        settings.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Página Inicial"),
                  onTap: () {
                    Navigator.pop(context); // Fecha o drawer
                    Navigator.pushReplacementNamed(context, "/");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_view_week),
                  title: Text("Todos os Hábitos"),
                  onTap: () {
                    Navigator.of(context).pushNamed('/todosHabitos');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.done_all),
                  title: const Text("Hábitos Concluídos"),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/concluidos');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.plus_one),
                  title: const Text("Novo Hábito"),
                  onTap: () async {
                    Navigator.pop(context); // Fecha o drawer antes de navegar
                    final result = await Navigator.pushNamed(
                      context,
                      "/formHabit",
                    );
                    if (result == true && onFormSaved != null) {
                      onFormSaved!(); // Atualiza a HomePage após retorno da tela
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_rounded),
                  title: const Text("Progresso"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, "/progress");
                  },
                ),
              ],
            ),
          ),
          // Rodapé fixo (Configurações)
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configurações"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/settings");
            },
          ),
        ],
      ),
    );
  }
}
