import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

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
        const Text(
          'Chave da API Google Gemini',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _keyController,
          obscureText: _isObscured,
          decoration: InputDecoration(
            hintText: 'Cole sua chave aqui',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.key),
            suffixIcon: IconButton(
              icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _isObscured = !_isObscured),
            ),
          ),
          onChanged: (val) {
            Provider.of<MealProvider>(context, listen: false).setApiKey(val);
          },
        ),


        const SizedBox(height: 8),
        const Text(
          'Necessária para a funcionalidade de IA Mágica.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        
        const SizedBox(height: 32),
         const Text(
          'Meta Diária',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Consumer<MealProvider>(
          builder: (context, provider, _) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${provider.goal} kcal'),
             trailing: const Icon(Icons.edit),
             onTap: () async {
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
