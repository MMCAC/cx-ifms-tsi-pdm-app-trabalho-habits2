import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressoChart extends StatelessWidget {
  final List<BarChartGroupData> dados;
  final String filtro;
  final List<String> labels;

  const ProgressoChart({
    super.key,
    required this.dados,
    required this.filtro,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: false,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value % 1 == 0 && value >= 0) {
                  return Text(value.toInt().toString());
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < labels.length) {
                  return Text(labels[value.toInt()]);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Mostra os valores no topo da barra
                final group = dados.firstWhere(
                  (g) => g.x == value.toInt(),
                  orElse: () => BarChartGroupData(x: value.toInt(), barRods: []),
                );

                if (group.barRods.isNotEmpty) {
                  final y = group.barRods[0].toY;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      y.toInt().toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: dados.map((bar) {
          return bar.copyWith(
            barRods: bar.barRods.map((rod) {
              return rod.copyWith(
                width: 18,
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
