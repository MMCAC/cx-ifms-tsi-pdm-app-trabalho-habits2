import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/appDrawer.dart';

class HabitFormPage extends StatefulWidget {
  const HabitFormPage({super.key});

  @override
  State<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final String baseUrl = "http://127.0.0.1:8080";

  final Map<String, bool> diasSelecionados = {
    'Segunda': false,
    'Terça': false,
    'Quarta': false,
    'Quinta': false,
    'Sexta': false,
    'Sábado': false,
    'Domingo': false,
  };

  Future<void> salvarHabito() async { 
    if (_formKey.currentState!.validate()) {
      final habito = {
        'nome': _nomeController.text.trim(),
        'seg': diasSelecionados['Segunda'],
        'ter': diasSelecionados['Terça'],
        'qua': diasSelecionados['Quarta'],
        'qui': diasSelecionados['Quinta'],
        'sex': diasSelecionados['Sexta'],
        'sab': diasSelecionados['Sábado'],
        'dom': diasSelecionados['Domingo'],
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/habito'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(habito),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (context.mounted) Navigator.pop(context, true); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar hábito: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar com o servidor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Novo Hábito')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do hábito',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Informe um nome válido' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Selecione os dias da semana:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...diasSelecionados.entries.map((entry) {
                return CheckboxListTile(
                  title: Text(entry.key),
                  value: entry.value,
                  onChanged: (val) {
                    setState(() {
                      diasSelecionados[entry.key] = val!;
                    });
                  },
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: salvarHabito,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Hábito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}