import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/habitoConcluido.dart';
import '../widgets/appDrawer.dart';

class TodosConcluidosPage extends StatefulWidget {
  const TodosConcluidosPage({super.key});

  @override
  State<TodosConcluidosPage> createState() => _TodosConcluidosPageState();
}

class _TodosConcluidosPageState extends State<TodosConcluidosPage> {
  final String baseUrl = "http://127.0.0.1:8080";
  List<HabitoConcluido> concluidos = [];

  @override
  void initState() {
    super.initState();
    carregarConcluidos();
  }

  Future<void> carregarConcluidos() async {
    try {
      final resp = await http.get(Uri.parse("$baseUrl/concluido"));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          concluidos = List<Map<String, dynamic>>.from(data)
              .map((e) => HabitoConcluido.fromJson(e))
              .toList();
        });
      } else {
        print("Erro ao carregar concluídos: ${resp.statusCode}");
      }
    } catch (e) {
      print("Erro de conexão: $e");
    }
  }

  Future<void> excluirHabitoConcluido(String id) async {
    try {
      final resp = await http.delete(Uri.parse("$baseUrl/concluido/$id"));
      if (resp.statusCode == 200) {
        await carregarConcluidos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hábito concluído excluído com sucesso."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao excluir hábito concluído."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("Erro ao excluir: $e");
    }
  }

  void abrirDialogEdicao(HabitoConcluido h) {
    final dataController = TextEditingController(
      text: h.dataConclusao.toIso8601String().substring(0, 10),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Conclusão"),
        content: TextField(
          controller: dataController,
          decoration:
              const InputDecoration(labelText: "Data de Conclusão (yyyy-mm-dd)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final body = {
                  "id": h.id,
                  "dataConclusao": dataController.text,
                };

                final resp = await http.put(
                  Uri.parse("$baseUrl/concluido"),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode(body),
                );

                if (resp.statusCode == 200) {
                  Navigator.pop(context);
                  await carregarConcluidos();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Erro ao editar conclusão"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erro: $e")),
                );
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hábitos Concluídos')),
      drawer: const AppDrawer(),
      body: concluidos.isEmpty
          ? const Center(child: Text("Nenhum hábito concluído encontrado."))
          : ListView.builder(
              itemCount: concluidos.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemBuilder: (context, index) {
                final h = concluidos[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: const Icon(Icons.done_all, color: Colors.green),
                    title: Text(
                      h.nome,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text("Concluído em: ${h.dataConclusao.day.toString().padLeft(2, '0')}/"
                          "${h.dataConclusao.month.toString().padLeft(2, '0')}/"
                          "${h.dataConclusao.year}"),
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
                                title: const Text("Excluir Conclusão"),
                                content: const Text("Tem certeza que deseja excluir este hábito concluído?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancelar"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      excluirHabitoConcluido(h.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
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
    );
  }
}
