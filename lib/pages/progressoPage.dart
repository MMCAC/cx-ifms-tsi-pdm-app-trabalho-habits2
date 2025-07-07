import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

import '../models/habitoConcluido.dart';
import '../widgets/appDrawer.dart';
import '../widgets/progressoChart.dart';

class ProgressoPage extends StatefulWidget {
  const ProgressoPage({super.key});

  @override
  State<ProgressoPage> createState() => _ProgressoPageState();
}

class _ProgressoPageState extends State<ProgressoPage> {
  final String baseUrl = "http://127.0.0.1:8080";

  List<HabitoConcluido> habitos = [];
  String filtro = 'todos';
  DateTime filtroData = DateTime.now();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    String endpoint;

    switch (filtro) {
      case 'todos':
        endpoint = '/concluido';
        break;
      case 'mes':
        endpoint = '/concluido/${filtroData.year}/${filtroData.month}';
        break;
      case 'dia':
        endpoint = '/concluido/${filtroData.year}/${filtroData.month}/${filtroData.day}';
        break;
      case 'ano':
        endpoint = '/concluido/nesteAno';  // fixo, seu backend só aceita assim
        break;
      case 'semana':
      default:
        endpoint = '/concluido/nestaSemana';
    }

    try {
      final resp = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          habitos = List<Map<String, dynamic>>.from(data)
              .map((e) => HabitoConcluido.fromJson(e))
              .toList();
        });
      } else {
        print("Erro ao carregar dados: ${resp.statusCode}");
        setState(() {
          habitos = [];
        });
      }
    } catch (e) {
      print("Erro de conexão: $e");
      setState(() {
        habitos = [];
      });
    }
  }

  List<BarChartGroupData> gerarGrafico() {
    switch (filtro) {
      case 'todos':
        final anosMap = <int, int>{};
        for (var h in habitos) {
          final ano = h.dataConclusao.year;
          anosMap[ano] = (anosMap[ano] ?? 0) + 1;
        }
        final anosOrdenados = anosMap.keys.toList()..sort();
        return List.generate(anosOrdenados.length, (index) {
          final ano = anosOrdenados[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: anosMap[ano]!.toDouble(), color: Colors.indigo),
            ],
          );
        });

      case 'mes':
        final meses = List.generate(12, (i) => 0);
        for (var h in habitos) {
          meses[h.dataConclusao.month - 1]++;
        }
        return List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: meses[i].toDouble(), color: Colors.indigo)],
          );
        });

      case 'ano':
      case 'dia':
        return [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: habitos.length.toDouble(), color: Colors.indigo)],
          )
        ];

      case 'semana':
      default:
        final dias = List.generate(7, (i) => 0);
        for (var h in habitos) {
          dias[h.dataConclusao.weekday - 1]++;
        }
        return List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: dias[i].toDouble(), color: Colors.indigo)],
          );
        });
    }
  }

  List<String> gerarLabels() {
    switch (filtro) {
      case 'todos':
        final anos = habitos.map((h) => h.dataConclusao.year).toSet().toList()..sort();
        return anos.map((ano) => ano.toString()).toList();

      case 'mes':
        return ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

      case 'semana':
        return ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

      case 'dia':
        return [formatarData(filtroData)];

      case 'ano':
        // sempre mostra o ano atual fixo, pois backend não suporta outro ano
        return [DateTime.now().year.toString()];

      default:
        return [];
    }
  }

  String formatarData(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}-${data.month.toString().padLeft(2, '0')}-${data.year}";
  }

  Widget buildResumoCard() {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white24
          : Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Resumo do período:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Concluídos: ${habitos.length}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text("Hábitos concluídos:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...habitos.map((h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text("• ${h.nome}", style: const TextStyle(fontSize: 15)),
            )),
          ],
        ),
      ),
    );
  }

  String getDescricaoFiltro() {
    switch (filtro) {
      case 'todos':
        return 'Visualize quantos hábitos foram concluídos por ano.';
      case 'semana':
        return 'Visualize seus hábitos concluídos nesta semana (segunda a domingo).';
      case 'mes':
        return 'Veja os hábitos concluídos no mês selecionado.';
      case 'ano':
        return 'Exibe o total de hábitos concluídos neste ano.';
      case 'dia':
        return 'Exibe quantos hábitos foram concluídos no dia selecionado.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progresso')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ToggleButtons(
              isSelected: [
                filtro == 'todos',
                filtro == 'semana',
                filtro == 'mes',
                filtro == 'ano',
                filtro == 'dia',
              ],
              onPressed: (index) {
                setState(() {
                  filtro = ['todos', 'semana', 'mes', 'ano', 'dia'][index];
                  // Quando trocar filtro, pode resetar filtroData para hoje
                  filtroData = DateTime.now();
                });
                carregarDados();
              },
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Todos')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Semana')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Mês')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Ano')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Dia')),
              ],
            ),
            const SizedBox(height: 16),
            Text(getDescricaoFiltro(), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            // Mostrar dropdowns apenas para 'mes' e 'dia'
            if (['mes', 'dia'].contains(filtro))
              Row(
                children: [
                  DropdownButton<int>(
                    value: filtroData.year,
                    items: List.generate(10, (i) => DateTime.now().year - 5 + i)
                        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          filtroData = DateTime(val, filtroData.month, filtroData.day);
                        });
                        carregarDados();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: filtroData.month,
                    items: List.generate(12, (i) => i + 1)
                        .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          filtroData = DateTime(filtroData.year, val, filtroData.day);
                        });
                        carregarDados();
                      }
                    },
                  ),
                  if (filtro == 'dia') ...[
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: filtroData.day,
                      items: List.generate(DateTime(filtroData.year, filtroData.month + 1, 0).day, (i) => i + 1)
                          .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            filtroData = DateTime(filtroData.year, filtroData.month, val);
                          });
                          carregarDados();
                        }
                      },
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 20),
            Expanded(
              child: habitos.isEmpty
                  ? const Center(child: Text('Nenhum dado para exibir'))
                  : Column(
                      children: [
                        Expanded(
                          child: ProgressoChart(
                            key: ValueKey(filtro + filtroData.toIso8601String()),
                            dados: gerarGrafico(),
                            filtro: filtro,
                            labels: gerarLabels(),
                          ),
                        ),
                        buildResumoCard(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';

// import '../models/habitoConcluido.dart';
// import '../widgets/appDrawer.dart';
// import '../widgets/progressoChart.dart';

// class ProgressoPage extends StatefulWidget {
//   const ProgressoPage({super.key});

//   @override
//   State<ProgressoPage> createState() => _ProgressoPageState();
// }

// class _ProgressoPageState extends State<ProgressoPage> {
//   final String baseUrl = "http://127.0.0.1:8080";

//   List<HabitoConcluido> habitos = [];
//   String filtro = 'todos';
//   DateTime filtroData = DateTime.now();

//   List<int> anosDisponiveis = [];

//   @override
//   void initState() {
//     super.initState();
//     carregarDados();
//   }

//   Future<void> carregarDados() async {
//     String endpoint;

//     switch (filtro) {
//       case 'todos':
//         endpoint = '/concluido';
//         break;
//       case 'mes':
//         endpoint = '/concluido/${filtroData.year}/${filtroData.month}';
//         break;
//       case 'dia':
//         endpoint = '/concluido/${filtroData.year}/${filtroData.month}/${filtroData.day}';
//         break;
//       case 'ano':
//         endpoint = '/concluido/nesteAno';
//         break;
//       case 'semana':
//       default:
//         endpoint = '/concluido/nestaSemana';
//     }

//     try {
//       final resp = await http.get(Uri.parse("$baseUrl$endpoint"));
//       if (resp.statusCode == 200) {
//         final data = json.decode(resp.body);
//         setState(() {
//           habitos = List<Map<String, dynamic>>.from(data)
//               .map((e) => HabitoConcluido.fromJson(e))
//               .toList();
//           anosDisponiveis = habitos.map((h) => h.dataConclusao.year).toSet().toList()..sort();
//         });
//       } else {
//         print("Erro ao carregar dados: ${resp.statusCode}");
//       }
//     } catch (e) {
//       print("Erro de conexão: $e");
//     }
//   }

//   List<BarChartGroupData> gerarGrafico() {
//     switch (filtro) {
//       case 'todos':
//         final anosMap = <int, int>{};
//         for (var h in habitos) {
//           final ano = h.dataConclusao.year;
//           anosMap[ano] = (anosMap[ano] ?? 0) + 1;
//         }

//         final anosOrdenados = anosMap.keys.toList()..sort();
//         return List.generate(anosOrdenados.length, (index) {
//           final ano = anosOrdenados[index];
//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: anosMap[ano]!.toDouble(),
//                 color: Colors.indigo,
//               ),
//             ],
//           );
//         });

//       case 'mes':
//         final meses = List.generate(12, (i) => 0);
//         for (var h in habitos) {
//           meses[h.dataConclusao.month - 1]++;
//         }
//         return List.generate(12, (i) {
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(toY: meses[i].toDouble(), color: Colors.indigo),
//             ],
//           );
//         });

//       case 'ano':
//       case 'dia':
//         final total = habitos.length;
//         return [
//           BarChartGroupData(
//             x: 0,
//             barRods: [
//               BarChartRodData(toY: total.toDouble(), color: Colors.indigo),
//             ],
//           )
//         ];

//       case 'semana':
//       default:
//         final dias = List.generate(7, (i) => 0);
//         for (var h in habitos) {
//           dias[h.dataConclusao.weekday - 1]++;
//         }
//         return List.generate(7, (i) {
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(toY: dias[i].toDouble(), color: Colors.indigo),
//             ],
//           );
//         });
//     }
//   }

//   Widget buildResumoCard() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.white24 : Colors.black26,
//             blurRadius: 6,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Resumo do período:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text("Concluídos: ${habitos.length}", style: const TextStyle(fontSize: 16)),
//           const SizedBox(height: 12),
//           const Text("Hábitos concluídos:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 6),
//           ...habitos.map((h) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 2.0),
//                 child: Text("• ${h.nome}", style: const TextStyle(fontSize: 15)),
//               )),
//         ],
//       ),
//     );
//   }

//   String getDescricaoFiltro() {
//     switch (filtro) {
//       case 'todos':
//         return 'Visualize quantos hábitos foram concluídos por ano.';
//       case 'semana':
//         return 'Visualize seus hábitos concluídos nesta semana (segunda a domingo).';
//       case 'mes':
//         return 'Veja os hábitos concluídos no mês selecionado.';
//       case 'ano':
//         return 'Exibe o total de hábitos concluídos neste ano.';
//       case 'dia':
//         return 'Exibe quantos hábitos foram concluídos no dia selecionado.';
//       default:
//         return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Progresso')),
//       drawer: const AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ToggleButtons(
//               isSelected: [
//                 filtro == 'todos',
//                 filtro == 'semana',
//                 filtro == 'mes',
//                 filtro == 'ano',
//                 filtro == 'dia',
//               ],
//               onPressed: (index) {
//                 setState(() {
//                   filtro = ['todos', 'semana', 'mes', 'ano', 'dia'][index];
//                 });
//                 carregarDados();
//               },
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Todos'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Semana'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Mês'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Ano'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Dia'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               getDescricaoFiltro(),
//               style: const TextStyle(fontSize: 16),
//             ),
//             if (filtro == 'dia') ...[
//               const SizedBox(height: 6),
//               Text(
//                 'Data selecionada: ${filtroData.day.toString().padLeft(2, '0')}-${filtroData.month.toString().padLeft(2, '0')}-${filtroData.year}',
//                 style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//               ),
//             ],
//             const SizedBox(height: 12),
//             if (['mes', 'ano', 'dia'].contains(filtro))
//               Row(
//                 children: [
//                   DropdownButton<int>(
//                     value: filtroData.year,
//                     items: anosDisponiveis
//                         .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
//                         .toList(),
//                     onChanged: (val) {
//                       if (val != null) {
//                         setState(() {
//                           filtroData = DateTime(val, filtroData.month, filtroData.day);
//                         });
//                         carregarDados();
//                       }
//                     },
//                   ),
//                   const SizedBox(width: 12),
//                   if (['mes', 'dia'].contains(filtro))
//                     DropdownButton<int>(
//                       value: filtroData.month,
//                       items: List.generate(12, (i) => i + 1)
//                           .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
//                           .toList(),
//                       onChanged: (val) {
//                         if (val != null) {
//                           setState(() {
//                             filtroData = DateTime(filtroData.year, val, filtroData.day);
//                           });
//                           carregarDados();
//                         }
//                       },
//                     ),
//                   const SizedBox(width: 12),
//                   if (filtro == 'dia')
//                     DropdownButton<int>(
//                       value: filtroData.day,
//                       items: List.generate(DateTime(filtroData.year, filtroData.month + 1, 0).day, (i) => i + 1)
//                           .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
//                           .toList(),
//                       onChanged: (val) {
//                         if (val != null) {
//                           setState(() {
//                             filtroData = DateTime(filtroData.year, filtroData.month, val);
//                           });
//                           carregarDados();
//                         }
//                       },
//                     ),
//                 ],
//               ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: habitos.isEmpty
//                   ? const Center(child: Text('Nenhum dado para exibir'))
//                   : Column(
//                       children: [
//                         Expanded(
//                           child: ProgressoChart(
//                             key: ValueKey(filtro + filtroData.toIso8601String()),
//                             dados: gerarGrafico(),
//                             filtro: filtro,
//                           ),
//                         ),
//                         buildResumoCard(),
//                       ],
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';

// import '../models/habitoConcluido.dart';
// import '../widgets/appDrawer.dart';
// import '../widgets/progressoChart.dart';

// class ProgressoPage extends StatefulWidget {
//   const ProgressoPage({super.key});

//   @override
//   State<ProgressoPage> createState() => _ProgressoPageState();
// }

// class _ProgressoPageState extends State<ProgressoPage> {
//   final String baseUrl = "http://127.0.0.1:8080";

//   List<HabitoConcluido> habitos = [];
//   String filtro = 'todos';
//   DateTime filtroData = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     carregarDados();
//   }

//   Future<void> carregarDados() async {
//     String endpoint;

//     switch (filtro) {
//       case 'todos':
//         endpoint = '/concluido';
//         break;
//       case 'mes':
//         endpoint = '/concluido/${filtroData.year}/${filtroData.month}';
//         break;
//       case 'dia':
//         endpoint = '/concluido/${filtroData.year}/${filtroData.month}/${filtroData.day}';
//         break;
//       case 'ano':
//         endpoint = '/concluido/nesteAno';
//         break;
//       case 'semana':
//       default:
//         endpoint = '/concluido/nestaSemana';
//     }

//     try {
//       final resp = await http.get(Uri.parse("$baseUrl$endpoint"));
//       if (resp.statusCode == 200) {
//         final data = json.decode(resp.body);
//         setState(() {
//           habitos = List<Map<String, dynamic>>.from(data)
//               .map((e) => HabitoConcluido.fromJson(e))
//               .toList();
//         });
//       } else {
//         print("Erro ao carregar dados: ${resp.statusCode}");
//       }
//     } catch (e) {
//       print("Erro de conexão: $e");
//     }
//   }

//   List<BarChartGroupData> gerarGrafico() {
//     switch (filtro) {
//       case 'todos':
//         final anosMap = <int, int>{};
//         for (var h in habitos) {
//           final ano = h.dataConclusao.year;
//           anosMap[ano] = (anosMap[ano] ?? 0) + 1;
//         }

//         final anosOrdenados = anosMap.keys.toList()..sort();
//         return List.generate(anosOrdenados.length, (index) {
//           final ano = anosOrdenados[index];
//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: anosMap[ano]!.toDouble(),
//                 color: Colors.indigo,
//               ),
//             ],
//           );
//         });

//       case 'mes':
//         final meses = List.generate(12, (i) => 0);
//         for (var h in habitos) {
//           meses[h.dataConclusao.month - 1]++;
//         }
//         return List.generate(12, (i) {
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(toY: meses[i].toDouble(), color: Colors.indigo),
//             ],
//           );
//         });

//       case 'ano':
//       case 'dia':
//         final total = habitos.length;
//         return [
//           BarChartGroupData(
//             x: 0,
//             barRods: [
//               BarChartRodData(toY: total.toDouble(), color: Colors.indigo),
//             ],
//           )
//         ];

//       case 'semana':
//       default:
//         final dias = List.generate(7, (i) => 0);
//         for (var h in habitos) {
//           dias[h.dataConclusao.weekday - 1]++;
//         }
//         return List.generate(7, (i) {
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(toY: dias[i].toDouble(), color: Colors.indigo),
//             ],
//           );
//         });
//     }
//   }

//   Widget buildResumoCard() {
//     final theme = Theme.of(context);

//     return Card(
//       color: theme.cardColor,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Resumo do período:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Text("Concluídos: ${habitos.length}", style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 12),
//             const Text("Hábitos concluídos:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 6),
//             ...habitos.map((h) => Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 2.0),
//                   child: Text("• ${h.nome}", style: const TextStyle(fontSize: 15)),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }

//   String getDescricaoFiltro() {
//     switch (filtro) {
//       case 'todos':
//         return 'Visualize quantos hábitos foram concluídos por ano.';
//       case 'semana':
//         return 'Visualize seus hábitos concluídos nesta semana (segunda a domingo).';
//       case 'mes':
//         return 'Veja os hábitos concluídos no mês selecionado.';
//       case 'ano':
//         return 'Exibe o total de hábitos concluídos neste ano.';
//       case 'dia':
//         return 'Exibe quantos hábitos foram concluídos no dia selecionado.';
//       default:
//         return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Progresso')),
//       drawer: const AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ToggleButtons(
//               isSelected: [
//                 filtro == 'todos',
//                 filtro == 'semana',
//                 filtro == 'mes',
//                 filtro == 'ano',
//                 filtro == 'dia',
//               ],
//               onPressed: (index) {
//                 setState(() {
//                   filtro = ['todos', 'semana', 'mes', 'ano', 'dia'][index];
//                 });
//                 carregarDados();
//               },
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Todos'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Semana'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Mês'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Ano'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Dia'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               getDescricaoFiltro(),
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 12),
//             if (['mes', 'ano', 'dia'].contains(filtro))
//               Row(
//                 children: [
//                   DropdownButton<int>(
//                     value: filtroData.year,
//                     items: List.generate(10, (i) => DateTime.now().year - 5 + i)
//                         .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
//                         .toList(),
//                     onChanged: (val) {
//                       if (val != null) {
//                         setState(() {
//                           filtroData = DateTime(val, filtroData.month, filtroData.day);
//                         });
//                         carregarDados();
//                       }
//                     },
//                   ),
//                   const SizedBox(width: 12),
//                   if (['mes', 'dia'].contains(filtro))
//                     DropdownButton<int>(
//                       value: filtroData.month,
//                       items: List.generate(12, (i) => i + 1)
//                           .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
//                           .toList(),
//                       onChanged: (val) {
//                         if (val != null) {
//                           setState(() {
//                             filtroData = DateTime(filtroData.year, val, filtroData.day);
//                           });
//                           carregarDados();
//                         }
//                       },
//                     ),
//                   const SizedBox(width: 12),
//                   if (filtro == 'dia')
//                     DropdownButton<int>(
//                       value: filtroData.day,
//                       items: List.generate(DateTime(filtroData.year, filtroData.month + 1, 0).day, (i) => i + 1)
//                           .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
//                           .toList(),
//                       onChanged: (val) {
//                         if (val != null) {
//                           setState(() {
//                             filtroData = DateTime(filtroData.year, filtroData.month, val);
//                           });
//                           carregarDados();
//                         }
//                       },
//                     ),
//                 ],
//               ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: habitos.isEmpty
//                   ? const Center(child: Text('Nenhum dado para exibir'))
//                   : Column(
//                       children: [
//                         Expanded(
//                           child: ProgressoChart(
//                             key: ValueKey(filtro + filtroData.toIso8601String()),
//                             dados: gerarGrafico(),
//                             filtro: filtro,
//                           ),
//                         ),
//                         buildResumoCard(),
//                       ],
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';

// import '../models/habitoConcluido.dart';
// import '../widgets/appDrawer.dart';
// import '../widgets/progressoChart.dart';

// class ProgressoPage extends StatefulWidget {
//   const ProgressoPage({super.key});

//   @override
//   State<ProgressoPage> createState() => _ProgressoPageState();
// }

// class _ProgressoPageState extends State<ProgressoPage> {
//   final String baseUrl = "http://127.0.0.1:8080";

//   List<HabitoConcluido> habitos = [];
//   String filtro = 'todos';
//   DateTime filtroData = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     carregarDados();
//   }

//   Future<void> carregarDados() async {
//     String endpoint;

//     switch (filtro) {
//       case 'todos':
//         endpoint = '/concluido';
//         break;
//       case 'mes':
//         endpoint = '/concluido/${filtroData.year}/${filtroData.month}';
//         break;
//       case 'dia':
//         endpoint =
//             '/concluido/${filtroData.year}/${filtroData.month}/${filtroData.day}';
//         break;
//       case 'ano':
//         endpoint = '/concluido/nesteAno';
//         break;
//       case 'semana':
//       default:
//         endpoint = '/concluido/nestaSemana';
//     }

//     try {
//       final resp = await http.get(Uri.parse("$baseUrl$endpoint"));
//       if (resp.statusCode == 200) {
//         final data = json.decode(resp.body);
//         setState(() {
//           habitos = List<Map<String, dynamic>>.from(data)
//               .map((e) => HabitoConcluido.fromJson(e))
//               .toList();
//         });
//       } else {
//         print("Erro ao carregar dados: ${resp.statusCode}");
//       }
//     } catch (e) {
//       print("Erro de conexão: $e");
//     }
//   }

//   List<BarChartGroupData> gerarGrafico() {
//     switch (filtro) {
//       case 'todos':
//         final anosMap = <int, int>{};
//         for (var h in habitos) {
//           final ano = h.dataConclusao.year;
//           anosMap[ano] = (anosMap[ano] ?? 0) + 1;
//         }

//         final anosOrdenados = anosMap.keys.toList()..sort();
//         return List.generate(anosOrdenados.length, (index) {
//           final ano = anosOrdenados[index];
//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: anosMap[ano]!.toDouble(),
//                 color: Colors.indigo,
//               ),
//             ],
//             showingTooltipIndicators: [0],
//           );
//         });

//       case 'mes':
//         final meses = List.generate(12, (i) => 0);
//         for (var h in habitos) {
//           meses[h.dataConclusao.month - 1]++;
//         }
//         return List.generate(12, (i) {
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(toY: meses[i].toDouble(), color: Colors.indigo),
//             ],
//           );
//         });

//       case 'ano':
//         final total = habitos.length;
//         return [
//           BarChartGroupData(
//             x: 0,
//             barRods: [
//               BarChartRodData(toY: total.toDouble(), color: Colors.indigo),
//             ],
//           )
//         ];

//       case 'dia':
//         final totalDia = habitos.length;
//         return [
//           BarChartGroupData(
//             x: 0,
//             barRods: [
//               BarChartRodData(toY: totalDia.toDouble(), color: Colors.indigo),
//             ],
//           )
//         ];

//       case 'semana':
//       default:
//         final dias = List.generate(7, (i) => 0);
//         for (var h in habitos) {
//           dias[h.dataConclusao.weekday - 1]++;
//         }
//         return List.generate(7, (i) {
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(toY: dias[i].toDouble(), color: Colors.indigo),
//             ],
//           );
//         });
//     }
//   }

//   Widget buildDateSelectors() {
//     final anoAtual = DateTime.now().year;
//     final anos = List.generate(10, (i) => anoAtual - 5 + i);
//     int diasNoMes = DateTime(filtroData.year, filtroData.month + 1, 0).day;

//     return Row(
//       children: [
//         DropdownButton<int>(
//           value: filtroData.year,
//           items: anos
//               .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
//               .toList(),
//           onChanged: (val) {
//             if (val != null) {
//               setState(() {
//                 filtroData = DateTime(val, filtroData.month, filtroData.day);
//               });
//               carregarDados();
//             }
//           },
//         ),
//         const SizedBox(width: 12),
//         DropdownButton<int>(
//           value: filtroData.month,
//           items: List.generate(12, (i) => i + 1)
//               .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
//               .toList(),
//           onChanged: (val) {
//             if (val != null) {
//               int dia = filtroData.day <=
//                       DateTime(filtroData.year, val + 1, 0).day
//                   ? filtroData.day
//                   : 1;
//               setState(() {
//                 filtroData = DateTime(filtroData.year, val, dia);
//               });
//               carregarDados();
//             }
//           },
//         ),
//         const SizedBox(width: 12),
//         if (filtro == 'dia')
//           DropdownButton<int>(
//             value: filtroData.day,
//             items: List.generate(diasNoMes, (i) => i + 1)
//                 .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
//                 .toList(),
//             onChanged: (val) {
//               if (val != null) {
//                 setState(() {
//                   filtroData = DateTime(
//                       filtroData.year, filtroData.month, val);
//                 });
//                 carregarDados();
//               }
//             },
//           ),
//       ],
//     );
//   }

//   String getDescricaoFiltro() {
//     switch (filtro) {
//       case 'todos':
//         return 'Visualize quantos hábitos foram concluídos por ano.';
//       case 'semana':
//         return 'Visualize seus hábitos concluídos nesta semana (segunda a domingo).';
//       case 'mes':
//         return 'Veja os hábitos concluídos no mês selecionado.';
//       case 'ano':
//         return 'Exibe o total de hábitos concluídos neste ano.';
//       case 'dia':
//         return 'Exibe quantos hábitos foram concluídos no dia selecionado.';
//       default:
//         return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Progresso')),
//       drawer: const AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ToggleButtons(
//               isSelected: [
//                 filtro == 'todos',
//                 filtro == 'semana',
//                 filtro == 'mes',
//                 filtro == 'ano',
//                 filtro == 'dia',
//               ],
//               onPressed: (index) {
//                 setState(() {
//                   filtro = ['todos', 'semana', 'mes', 'ano', 'dia'][index];
//                 });
//                 carregarDados();
//               },
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Todos'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Semana'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Mês'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Ano'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('Dia'),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             Text(
//               getDescricaoFiltro(),
//               style: const TextStyle(fontSize: 16),
//             ),

//             const SizedBox(height: 12),

//             if (['mes', 'ano', 'dia'].contains(filtro)) buildDateSelectors(),

//             const SizedBox(height: 20),

//             Expanded(
//               child: habitos.isEmpty
//                   ? const Center(child: Text('Nenhum dado para exibir'))
//                   : AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: ProgressoChart(
//                         key: ValueKey(filtro + filtroData.toIso8601String()),
//                         dados: gerarGrafico(),
//                         filtro: filtro,
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';

// import '../models/habitoConcluido.dart';
// import '../widgets/appDrawer.dart';
// import '../widgets/progressoChart.dart';

// class ProgressoPage extends StatefulWidget {
//   const ProgressoPage({super.key});

//   @override
//   State<ProgressoPage> createState() => _ProgressoPageState();
// }

// class _ProgressoPageState extends State<ProgressoPage> {
//   final String baseUrl = "http://127.0.0.1:8080";

//   List<HabitoConcluido> habitos = [];
//   String filtro = 'semana';

//   @override
//   void initState() {
//     super.initState();
//     carregarDados();
//   }

//   Future<void> carregarDados() async {
//     String endpoint;
//     switch (filtro) {
//       case 'mes':
//         endpoint = '/concluido/nesteAno';
//         break;
//       case 'ano':
//         endpoint = '/concluido/ultimosAnos';
//         break;
//       case 'semana':
//       default:
//         endpoint = '/concluido/nestaSemana';
//     }
//     final resp = await http.get(Uri.parse("$baseUrl$endpoint"));
//     final data = json.decode(resp.body);
//     setState(() {
//       habitos = List<Map<String, dynamic>>.from(data)
//           .map((e) => HabitoConcluido.fromJson(e))
//           .toList();
//     });
//   }

//   List<BarChartGroupData> gerarGrafico() {
//     switch (filtro) {
//       case 'mes':
//         final meses = List.generate(12, (i) => 0);
//         for (var h in habitos) {
//           meses[h.dataConclusao.month - 1]++;
//         }
//         return List.generate(12, (i) {
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(toY: meses[i].toDouble(), color: Colors.indigo),
//             ],
//           );
//         });

//       case 'ano':
//         final anoAtual = DateTime.now().year;
//         final anos = Map.fromIterable(
//           List.generate(10, (i) => anoAtual - 5 + i),
//           key: (e) => e,
//           value: (_) => 0,
//         );

//         for (var h in habitos) {
//           final ano = h.dataConclusao.year;
//           if (anos.containsKey(ano)) {
//             anos[ano] = (anos[ano] ?? 0) + 1;
//           }
//         }

//         return anos.entries.map((entry) {
//           final index = entry.key - (anoAtual - 5);
//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: entry.value.toDouble(),
//                 color: Colors.indigo,
//               ),
//             ],
//           );
//         }).toList();

//       case 'semana':
//       default:
//         final dias = List.generate(7, (i) => 0);
//         for (var h in habitos) {
//           dias[h.dataConclusao.weekday - 1]++;
//         }
//         return List.generate(7, (i) {
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(toY: dias[i].toDouble(), color: Colors.indigo),
//             ],
//           );
//         });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Progresso')),
//       drawer: const AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ToggleButtons(
//               isSelected: [
//                 filtro == 'semana',
//                 filtro == 'mes',
//                 filtro == 'ano',
//               ], 
//               onPressed: (index) {
//                 setState(() {
//                   filtro = ['semana', 'mes', 'ano'][index];
//                   carregarDados();
//                 });
//               },
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Text('Semana'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Text('Mês'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Text('Ano'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: habitos.isEmpty
//                   ? const Center(child: Text('Nenhum dado para exibir'))
//                   : AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: ProgressoChart(
//                         key: ValueKey(filtro),
//                         dados: gerarGrafico(),
//                         filtro: filtro,
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
