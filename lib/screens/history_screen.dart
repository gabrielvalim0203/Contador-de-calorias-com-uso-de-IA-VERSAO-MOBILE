import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final allMeals = provider.meals;

    // Group meals by date string (YYYY-MM-DD)
    final Map<String, List<Meal>> grouped = {};
    for (var meal in allMeals) {
      final key = DateFormat('yyyy-MM-dd').format(meal.date);
      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(meal);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    if (sortedKeys.isEmpty) {
      return const Center(child: Text('Sem histórico ainda.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final dayMeals = grouped[dateKey]!;
        final total = dayMeals.fold(0, (sum, m) => sum + m.calories);
        final date = dayMeals.first.date;
        final goal = provider.goal;
        final percent = (total / goal).clamp(0.0, 1.0);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(date),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '$total / $goal kcal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600, 
                        color: total > goal ? Colors.red : Colors.green
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.grey.shade100,
                  color: total > goal ? Colors.red : Colors.green,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 12),
                if (dayMeals.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      children: dayMeals.take(3).map((m) => Chip(
                        label: Text(m.name, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.grey.shade50,
                      )).toList(),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
