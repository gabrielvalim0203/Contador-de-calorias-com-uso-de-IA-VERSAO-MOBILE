import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../models/meal.dart';

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
        return Hero(
          tag: 'meal-${meal.id}',
          child: Card(
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFF1F5F9)) // slate-100
                ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                meal.name,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${meal.calories} kcal',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSmallMacro('P', '${meal.protein}g', const Color(0xFFFCA5A5)),
                      const SizedBox(width: 8),
                      _buildSmallMacro('C', '${meal.carbs}g', const Color(0xFFFDBA74)),
                      const SizedBox(width: 8),
                      _buildSmallMacro('G', '${meal.fat}g', const Color(0xFF93C5FD)),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF94A3B8)),
                    onPressed: () => _showEditDialog(context, provider, meal),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFF94A3B8)),
                    onPressed: () => provider.removeMeal(meal.id),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, MealProvider provider, Meal meal) async {
    final nameController = TextEditingController(text: meal.name);
    final calController = TextEditingController(text: meal.calories.toString());
    final proteinController = TextEditingController(text: meal.protein.toString());
    final carbsController = TextEditingController(text: meal.carbs.toString());
    final fatController = TextEditingController(text: meal.fat.toString());
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Refeição'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
              TextField(controller: calController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calorias')),
              Row(
                children: [
                  Expanded(child: TextField(controller: proteinController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prot (g)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: carbsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carb (g)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: fatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gord (g)'))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salvar')),
        ],
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      final calories = int.tryParse(calController.text);
      if (name.isNotEmpty && calories != null) {
        provider.updateMeal(
          meal.id, 
          name, 
          calories,
          protein: int.tryParse(proteinController.text) ?? 0,
          carbs: int.tryParse(carbsController.text) ?? 0,
          fat: int.tryParse(fatController.text) ?? 0,
        );
      }
    }
  }

  Widget _buildSmallMacro(String label, String value, Color color) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(color: color.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
