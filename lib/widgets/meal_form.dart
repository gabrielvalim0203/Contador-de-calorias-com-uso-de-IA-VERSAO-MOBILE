import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class MealFormModal extends StatefulWidget {
  const MealFormModal({super.key});

  @override
  State<MealFormModal> createState() => _MealFormModalState();
}

class _MealFormModalState extends State<MealFormModal> {
  final _nameController = TextEditingController();
  final _calController = TextEditingController();

  void _submit() {
    final name = _nameController.text.trim();
    final calories = int.tryParse(_calController.text) ?? 0;

    if (name.isNotEmpty && calories > 0) {
      Provider.of<MealProvider>(context, listen: false).addMeal(name, calories);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Autocomplete logic could go here using provider.history
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Adicionar Refeição Manualmente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome da refeição',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fastfood_outlined),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _calController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calorias (kcal)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_fire_department_outlined),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16), 
            ),
            child: const Text('Adicionar'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
