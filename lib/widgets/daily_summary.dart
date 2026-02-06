import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class DailySummary extends StatelessWidget {
  const DailySummary({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final total = provider.totalCalories;
    final goal = provider.goal;
    
    int percentage = ((total / goal) * 100).round();
    if (percentage > 100) percentage = 100;
    
    final isOver = total > goal;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calorias Hoje',
                    style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '$total',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                   // Simple dialog to update goal
                   final controller = TextEditingController(text: goal.toString());
                   final newGoal = await showDialog<int>(
                     context: context,
                     builder: (ctx) => AlertDialog(
                       title: const Text('Meta Diária'),
                       content: TextField(
                         controller: controller,
                         keyboardType: TextInputType.number,
                         decoration: const InputDecoration(labelText: 'Calorias'),
                       ),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                         TextButton(
                           onPressed: () {
                             final val = int.tryParse(controller.text);
                             if (val != null) Navigator.pop(ctx, val);
                           },
                           child: const Text('Salvar'),
                         ),
                       ],
                     ),
                   );
                   
                   if (newGoal != null) {
                     provider.setGoal(newGoal);
                   }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Row(
                        children: [
                          Text('META', style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 10, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.flag, size: 12, color: Color(0xFFC7D2FE)),
                        ],
                      ),
                      Text(
                        '$goal',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF312E81).withOpacity(0.3), // indigo-900/30
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  color: isOver ? const Color(0xFFF87171) : const Color(0xFF34D399), // red-400 or emerald-400
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0%', style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12)),
              Text('$percentage% da meta', style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (ctx) => AlertDialog(
                    title: const Text('Concluir Dia?'),
                    content: Text('Total consumido: $total kcal\n\nIsso irá iniciar um novo dia em branco.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                      ElevatedButton(
                        onPressed: () {
                          provider.completeDay();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Confirmar'),
                      )
                    ],
                  ),
                );
              },
              icon: const Text('✅'),
              label: const Text('Concluir Dia', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                backgroundColor: Colors.white.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
