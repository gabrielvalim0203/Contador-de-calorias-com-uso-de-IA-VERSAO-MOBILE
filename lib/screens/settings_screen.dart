import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../models/user_profile.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _keyController = TextEditingController();
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MealProvider>(context, listen: false);
    _keyController.text = provider.apiKey;
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Configurações',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Perfil Section
        const Text(
          'Dados do Usuário',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo),
        ),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFEEF2FF),
            child: Icon(Icons.person, color: Colors.indigo),
          ),
          title: const Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Peso, altura e cálculo de TMB'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),

        const SizedBox(height: 32),
         const Text(
          'Meta Diária',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Consumer<MealProvider>(
          builder: (context, provider, _) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            title: Text('${provider.goal} kcal'),
             subtitle: Text(provider.profile.useAutoGoal ? 'Calculada automaticamente' : 'Definida manualmente'),
             trailing: provider.profile.useAutoGoal ? const Icon(Icons.bolt, color: Colors.amber) : const Icon(Icons.edit),
             onTap: () async {
                   if (provider.profile.useAutoGoal) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('A meta está automática. Altere no seu Perfil.')),
                     );
                     return;
                   }

                   final controller = TextEditingController(text: provider.goal.toString());
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
                   if(newGoal != null) provider.setGoal(newGoal);
             },
          ),
        ),
      ],
    );
  }
}
