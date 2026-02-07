import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  late String _selectedGender;
  late double _selectedActivity;
  late bool _useAutoGoal;

  final Map<double, String> _activityLevels = {
    1.2: 'Sedentário (pouco ou nenhum exercício)',
    1.375: 'Leve (exercício 1-3 dias/semana)',
    1.55: 'Moderado (exercício 3-5 dias/semana)',
    1.725: 'Ativo (exercício 6-7 dias/semana)',
    1.9: 'Muito Ativo (trabalho físico ou treino intenso)',
  };

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MealProvider>(context, listen: false);
    final profile = provider.profile;
    _weightController = TextEditingController(text: profile.weight.toString());
    _heightController = TextEditingController(text: profile.height.toString());
    _ageController = TextEditingController(text: profile.age.toString());
    _selectedGender = profile.gender;
    _selectedActivity = profile.activityLevel;
    _useAutoGoal = profile.useAutoGoal;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final provider = Provider.of<MealProvider>(context, listen: false);
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final height = double.tryParse(_heightController.text) ?? 170.0;
    final age = int.tryParse(_ageController.text) ?? 25;

    provider.updateProfile(UserProfile(
      weight: weight,
      height: height,
      age: age,
      gender: _selectedGender,
      activityLevel: _selectedActivity,
      useAutoGoal: _useAutoGoal,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final tdee = provider.calculatedTDEE;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Dados Físicos'),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Peso (kg)', _weightController, TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Altura (cm)', _heightController, TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Idade', _ageController, TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Gênero', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
                              DropdownButton<String>(
                                value: _selectedGender,
                                isExpanded: true,
                                underline: Container(height: 1, color: Colors.indigo.withOpacity(0.3)),
                                items: ['Masculino', 'Feminino'].map((String value) {
                                  return DropdownMenuItem<String>(value: value, child: Text(value));
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedGender = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Nível de Atividade'),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<double>(
                  value: _selectedActivity,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _activityLevels.entries.map((e) {
                    return DropdownMenuItem<double>(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 14)));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedActivity = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gasto Diário Estimado', style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('$tdee kcal', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.bolt, color: Colors.amber, size: 32),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Usar Meta Automática', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Ajusta sua meta conforme os dados acima'),
              value: _useAutoGoal,
              activeColor: Colors.indigo,
              onChanged: (val) => setState(() => _useAutoGoal = val),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Salvar Alterações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
        TextField(
          controller: controller,
          keyboardType: type,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBD5E1))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigo)),
          ),
          onChanged: (_) => setState(() {}), // To update calculated TDEE in real-time
        ),
      ],
    );
  }
}
