import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class AIInput extends StatefulWidget {
  const AIInput({super.key});

  @override
  State<AIInput> createState() => _AIInputState();
}

class _AIInputState extends State<AIInput> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<MealProvider>(context, listen: false);
    if (provider.apiKey.isEmpty) {
      setState(() => _error = 'Configure sua API Key nas configurações primeiro.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final modelsToTry = [
      "gemini-2.5-flash",
      "gemini-2.0-flash",
      "gemini-1.5-flash",
      "gemini-pro"
    ];

    bool success = false;
    String? lastErrorMessage;

    for (final modelName in modelsToTry) {
      try {
        debugPrint('Tentando modelo: $modelName');
        final model = GenerativeModel(
          model: modelName,
          apiKey: provider.apiKey.trim(),
        );

        const prompt = '''
          Analise a seguinte descrição de refeição e retorne APENAS um JSON array.
          Para cada item identificado, estime as calorias aproximadas.
          Se a quantidade não for especificada, assuma uma porção média padrão.
          Responda APENAS o JSON, sem markdown ou explicações.
          Formato: [{"name": "Nome do item", "calories": 0}]
          
          Refeição:
        ''';

        final content = [Content.text('$prompt "$text"')];
        final response = await model.generateContent(content);
        
        String responseText = response.text ?? '';
        // Cleanup markdown code blocks if present
        responseText = responseText.replaceAll(RegExp(r'```json|```'), '').trim();

        final List<dynamic> jsonList = jsonDecode(responseText);
        
        if (jsonList.isNotEmpty) {
          int count = 0;
          for (var item in jsonList) {
            if (item is Map && item.containsKey('name') && item.containsKey('calories')) {
              provider.addMeal(item['name'], item['calories']);
              count++;
            }
          }
           if (count > 0) {
            _controller.clear();
            success = true;
            break; 
           }
        }
      } catch (e) {
        debugPrint('Falha com $modelName: $e');
        lastErrorMessage = e.toString();
      }
    }

    if (!success && mounted) {
      setState(() => _error = 'Erro: $lastErrorMessage. Verifique sua chave.');
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, size: 18, color: Colors.indigo),
              ),
              const SizedBox(width: 8),
              const Text(
                'IA Mágica',
                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)), // slate-800
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 2,
            decoration: InputDecoration(
              hintText: 'Ex: 2 ovos fritos, 1 pão francês...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC), // slate-50
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // slate-200
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.indigo, width: 2),
              ),
            ),
            onChanged: (val) => setState(() {}),
            onSubmitted: (_) => _analyze(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: (_loading || _controller.text.isEmpty) ? null : _analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: _loading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.send, size: 20),
              label: const Text('Enviar'),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
