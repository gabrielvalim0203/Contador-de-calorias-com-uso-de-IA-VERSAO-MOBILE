import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class MealList extends StatelessWidget {
  const MealList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final meals = provider.currentMeals;

    if (meals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Column(
            children: [
              Icon(Icons.restaurant, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Nenhuma refeição registrada hoje.',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFF1F5F9)) // slate-100
              ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              meal.name,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            subtitle: Text(
              '${meal.calories} kcal',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF94A3B8)),
                  onPressed: () async {
                    final nameController = TextEditingController(text: meal.name);
                    final calController = TextEditingController(text: meal.calories.toString());
                    
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Editar Refeição'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: 'Nome'),
                            ),
                            TextField(
                              controller: calController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Calorias'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Salvar'),
                          ),
                        ],
                      ),
                    );

                    if (result == true) {
                      final name = nameController.text.trim();
                      final calories = int.tryParse(calController.text);
                      if (name.isNotEmpty && calories != null) {
                        provider.updateMeal(meal.id, name, calories);
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    provider.removeMeal(meal.id);
                  },
                ),
              ],
            ),

          ),
        );
      },
    );
  }
}
