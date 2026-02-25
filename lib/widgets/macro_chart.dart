import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class MacroChart extends StatelessWidget {
  const MacroChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final total = provider.totalProtein + provider.totalCarbs + provider.totalFat;

    if (total == 0) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: const Text(
          'Adicione alimentos para ver o gráfico',
          style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 30,
          sections: [
            PieChartSectionData(
              color: const Color(0xFFFCA5A5), // Proteins
              value: provider.totalProtein.toDouble(),
              title: '${((provider.totalProtein / total) * 100).toStringAsFixed(0)}%',
              radius: 40,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: const Color(0xFFFDBA74), // Carbs
              value: provider.totalCarbs.toDouble(),
              title: '${((provider.totalCarbs / total) * 100).toStringAsFixed(0)}%',
              radius: 40,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: const Color(0xFF93C5FD), // Fats
              value: provider.totalFat.toDouble(),
              title: '${((provider.totalFat / total) * 100).toStringAsFixed(0)}%',
              radius: 40,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
