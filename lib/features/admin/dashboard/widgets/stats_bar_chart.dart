import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';

/// Grafico de barras simple y reutilizable para el dashboard.
///
/// Recibe los datos ya armados como una lista de (etiqueta, valor) para no
/// acoplarlo a ninguna fuente de datos en particular. Es una lista y no
/// un Map para que dos barras con la misma etiqueta no se pisen.
class StatsBarChart extends StatelessWidget {
  const StatsBarChart({super.key, required this.entries, this.height = 180});

  final List<MapEntry<String, num>> entries;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxValue = entries
        .map((e) => e.value.toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxValue == 0 ? 1 : maxValue * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      entries[index].key,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value.toDouble(),
                    color: AppColors.primary,
                    width: 16,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
