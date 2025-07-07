import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/habito.dart';
import '../widgets/appDrawer.dart';

class TodosHabitosPage extends StatefulWidget {
  const TodosHabitosPage({super.key});

  @override
  State<TodosHabitosPage> createState() => _TodosHabitosScreenState();
}

class _TodosHabitosScreenState extends State<TodosHabitosPage> {
  final String baseUrl = "http://127.0.0.1:8080";
  List<Habito> habitos = [];
  int? filtroDiaSemana;

  @override
  void initState() {
    super.initState();
    carregarHabitos();
  }

  Future<void> carregarHabitos() async {
    try {
      final endpoint = filtroDiaSemana == null
          ? '/habito'
          : '/habito/diaDaSemana/$filtroDiaSemana';

      final uri = Uri.parse("$baseUrl$endpoint");
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          habitos = List<Map<String, dynamic>>.from(data)
              .map((e) => Habito.fromJson(e))
              .toList();
        });
      } else {
        print("Erro ao carregar hábitos: ${resp.statusCode}");
      }
    } catch (e) {
      print("Erro de conexão: $e");
    }
  }

  Future<void> excluirHabito(String id) async {
    final resp = await http.delete(Uri.parse("$baseUrl/habito/id/$id"));
    if (resp.statusCode == 200) {
      await carregarHabitos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hábito excluído com sucesso"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao excluir hábito"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void abrirDialogEdicao(Habito habito) {
    final nomeController = TextEditingController(text: habito.nome);
    final dias = {
      'seg': habito.seg,
      'ter': habito.ter,
      'qua': habito.qua,
      'qui': habito.qui,
      'sex': habito.sex,
      'sab': habito.sab,
      'dom': habito.dom,
    };

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Editar Hábito"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: dias.keys.map((dia) {
                    return FilterChip(
                      label: Text(dia.toUpperCase()),
                      selected: dias[dia]!,
                      onSelected: (val) {
                        setDialogState(() {
                          dias[dia] = val;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final body = {
                  "id": habito.id,
                  "nome": nomeController.text,
                  ...dias,
                };

                final resp = await http.put(
                  Uri.parse("$baseUrl/habito"),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode(body),
                );

                if (resp.statusCode == 200) {
                  Navigator.pop(context);
                  await carregarHabitos();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Erro ao editar hábito"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget diasTexto(Habito h) {
    final dias = <String>[];
    if (h.seg) dias.add("Seg");
    if (h.ter) dias.add("Ter");
    if (h.qua) dias.add("Qua");
    if (h.qui) dias.add("Qui");
    if (h.sex) dias.add("Sex");
    if (h.sab) dias.add("Sab");
    if (h.dom) dias.add("Dom");
    return Text("Dias: ${dias.join(', ')}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos os Hábitos')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
              return ChoiceChip(
                label: Text(dias[index]),
                selected: filtroDiaSemana == index,
                onSelected: (_) {
                  setState(() {
                    filtroDiaSemana = filtroDiaSemana == index ? null : index;
                  });
                  carregarHabitos();
                },
              );
            }),
          ),
          const Divider(),
          Expanded(
            child: habitos.isEmpty
                ? const Center(child: Text("Nenhum hábito encontrado."))
                : ListView.builder(
                    itemCount: habitos.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemBuilder: (context, index) {
                      final h = habitos[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          leading: const Icon(Icons.check_circle_outline, color: Colors.indigo),
                          title: Text(h.nome,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: diasTexto(h),
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => abrirDialogEdicao(h),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Excluir Hábito"),
                                      content: const Text("Tem certeza que deseja excluir este hábito?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Cancelar"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            excluirHabito(h.id);
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          child: const Text("Excluir"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
