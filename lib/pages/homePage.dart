import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:trabalho/Widgets/habitTitle.dart';
import 'dart:convert';

import '../models/habito.dart';
import '../models/habitoConcluido.dart';
import '../widgets/appDrawer.dart';
import '../widgets/habit_item.dart';
import '../widgets/completed_habit_item.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomePage({super.key, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String baseUrl = "http://127.0.0.1:8080";
  List<Habito> habitos = [];
  List<HabitoConcluido> concluidos = [];

  String? habitoEditandoId;
  TextEditingController? editarController;

  @override
  void initState() {
    super.initState();
    verificarPopup();
    carregarHabitos();
  }

  Future<void> carregarHabitos() async {
    final respHabitos = await http.get(Uri.parse("$baseUrl/habito/hoje"));
    final respConcluidos = await http.get(Uri.parse("$baseUrl/concluido/hoje"));

    setState(() {
      habitos = List<Map<String, dynamic>>.from(json.decode(respHabitos.body))
          .map((e) => Habito.fromJson(e))
          .toList();
      concluidos = List<Map<String, dynamic>>.from(json.decode(respConcluidos.body))
          .map((e) => HabitoConcluido.fromJson(e))
          .toList();
    });
  }

  Future<void> concluirHabito(String id, String nome) async {
  final response = await http.post(
    Uri.parse("$baseUrl/concluido"),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({"habitoId": id, "nome": nome}),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hábito feito', style: TextStyle(color: Colors.white)),
        duration: Duration(milliseconds: 300),
        backgroundColor: Colors.green
      ),
    );
    carregarHabitos();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao concluir hábito', style: TextStyle(color: Colors.white)),
        duration: Duration(milliseconds: 300),
        backgroundColor: Colors.red
      ),
    );
  }
}

  Future<void> removerConclusao(BuildContext context, String id) async {
  try {
    final resp = await http.delete(Uri.parse("$baseUrl/concluido/$id"));
    if (resp.statusCode == 200) {
      await carregarHabitos();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hábito excluído'),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao excluir hábito'),
          backgroundColor: Colors.orange,
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Erro ao excluir hábito'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

  Future<void> verificarPopup() async {
    final prefs = await SharedPreferences.getInstance();
    final jaViu = prefs.getBool('jaViuPopup') ?? false;

    if (!jaViu) {
      await Future.delayed(Duration.zero);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Bem-vindo!'),
          content: const Text(
              'Este aplicativo ajuda você a registrar e acompanhar seus hábitos diários.\n'
              'Na tela inicial você pode marcar os hábitos do dia como feitos.\n'
              'Use o menu para adicionar hábitos e visualizar seu progresso.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      await prefs.setBool('jaViuPopup', true);
    }
  }

  bool isConcluido(String habitoId) {
    return concluidos.any((h) => h.habitoId == habitoId);
  }

  void iniciarEdicao(Habito habito) {
    setState(() {
      habitoEditandoId = habito.id;
      editarController = TextEditingController(text: habito.nome);
    });
  }

Future<void> salvarEdicao() async {
  if (habitoEditandoId == null || editarController == null) return;

  final novoNome = editarController!.text.trim();
  if (novoNome.isEmpty) return;

  // Encontre o hábito localmente para pegar os dias da semana
  final habitoAtual = habitos.firstWhere((h) => h.id == habitoEditandoId);

  final body = {
    "id": habitoEditandoId,
    "nome": novoNome,
    "seg": habitoAtual.seg,
    "ter": habitoAtual.ter,
    "qua": habitoAtual.qua,
    "qui": habitoAtual.qui,
    "sex": habitoAtual.sex,
    "sab": habitoAtual.sab,
    "dom": habitoAtual.dom,
  };

  final resp = await http.put(
    Uri.parse("$baseUrl/habito"),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(body),
  );

  if (resp.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hábito atualizado com sucesso'),
        backgroundColor: Colors.blue,
        duration: Duration(milliseconds: 300),
      ),
    );
    await carregarHabitos(); // Atualiza a lista
    setState(() {
      habitoEditandoId = null;
      editarController?.dispose();
      editarController = null;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao atualizar hábito'),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 300),
      ),
    );
  }
}

Future<void> deletarHabito(String id) async {
  final response = await http.delete(Uri.parse('$baseUrl/habito/id/$id'));

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hábito deletado com sucesso'),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 300),
      ),
    );
    await carregarHabitos(); // Atualiza a lista após deletar
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao deletar hábito'),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 300),
      ),
    );
  }
}

  void cancelarEdicao() {
    setState(() {
      habitoEditandoId = null;
      editarController?.dispose();
      editarController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final semana = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado", "Domingo"];

    return Scaffold(
      appBar: AppBar(
      title: HabitTitle(
        title: 'Hábitos de Hoje',
        color: Theme.of(context).colorScheme.primary,
        onToggleTheme: widget.toggleTheme,  // passa o toggle do tema da main
      ),
    ),
      drawer: AppDrawer(onFormSaved: carregarHabitos,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              semana[hoje.weekday - 1],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...habitos.map((h) {
              final estaEditando = habitoEditandoId == h.id;

              if (estaEditando) {
                return ListTile(
                  title: TextField(
                    controller: editarController,
                    decoration: const InputDecoration(labelText: 'Editar hábito'),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: salvarEdicao,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: cancelarEdicao,
                      ),
                    ],
                  ),
                );
              } else {
                return HabitItem(
                  nome: h.nome,
                  concluido: isConcluido(h.id),
                  onConcluir: () => concluirHabito(h.id, h.nome),
                  onEditar: () => iniciarEdicao(h),
                  onRemover: () => deletarHabito(h.id),
                );
              }
            }).toList(),
            const Divider(),
            const Text(
              'Concluídos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...concluidos.map((h) => CompletedHabitItem(
                  nome: h.nome,
                  onRemover: () => removerConclusao(context, h.id),
                ))
          ],
        ),
      ),
    );
  }
}