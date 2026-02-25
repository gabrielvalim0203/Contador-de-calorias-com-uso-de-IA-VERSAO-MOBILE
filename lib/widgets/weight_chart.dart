import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/weight_provider.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeightProvider>(context);
    final logs = provider.weightLogs.reversed.toList(); // Oldest first for chart

    if (logs.length < 2) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'Adicione pelo menos 2 registros para ver o gráfico de progresso.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      );
    }

    // Get min/max for scaling
    double minWeight = logs.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    double maxWeight = logs.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < logs.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('dd/MM').format(logs[value.toInt()].date),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}kg',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
                  reservedSize: 40,
                ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (logs.length - 1).toDouble(),
          minY: minWeight,
          maxY: maxWeight,
          lineBarsData: [
            LineChartBarData(
              spots: logs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
              isCurved: true,
              color: Colors.indigo,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.indigo.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
