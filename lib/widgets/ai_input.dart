import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/meal_provider.dart';
import 'skeleton.dart';

class AIInput extends StatefulWidget {
  const AIInput({super.key});

  @override
  State<AIInput> createState() => _AIInputState();
}

class _AIInputState extends State<AIInput> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  XFile? _imageFile;
  bool _loading = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _imageFile == null) return;

    final provider = Provider.of<MealProvider>(context, listen: false);
    final String trimmedKey = provider.apiKey.trim();
    if (trimmedKey.isEmpty) {
      setState(() => _error = 'API Key não configurada. Adicione uma chave no menu de configurações para usar esta funcionalidade.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    List<String> discoveredModels = [];
    String discoveryError = "";
    try {
      final diagRes = await http.get(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$trimmedKey')).timeout(const Duration(seconds: 5));
      if (diagRes.statusCode == 200) {
        final data = jsonDecode(diagRes.body);
        discoveredModels = (data['models'] as List?)
            ?.map((m) => (m['name'] as String).replaceFirst('models/', ''))
            .where((name) => name.contains('flash') || name.contains('pro'))
            .toList() ?? [];
      } else {
        discoveryError = "Falha HTTP ${diagRes.statusCode}";
      }
    } catch (e) {
      discoveryError = "Erro rede: $e";
    }

    final Set<String> modelNames = {
      "gemini-2.0-flash",
      "gemini-flash-latest",
      "gemini-2.5-flash",
      "gemini-1.5-flash",
      "gemini-1.5-pro",
    };
    modelNames.addAll(discoveredModels);

    bool success = false;
    String? lastErrorMessage;

    for (final modelName in modelNames) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: trimmedKey,
          requestOptions: RequestOptions(apiVersion: "v1beta"),
        );

        final prompt = '''
          Analise a seguinte ${ _imageFile != null ? 'imagem e ' : '' }descrição de refeição e retorne APENAS um JSON array válido.
          Para cada item identificado na refeição, estime:
          - Nome do item
          - Calorias (int)
          - Proteínas em gramas (int)
          - Carboidratos em gramas (int)
          - Gorduras em gramas (int)
          
          Se a quantidade não for especificada, assuma uma porção média padrão.
          Responda EXCLUSIVAMENTE o código JSON, sem formatação markdown ou textos adicionais.
          Formato: [{"name": "Item", "calories": 0, "protein": 0, "carbs": 0, "fat": 0}]
          
          Refeição: ${text.isNotEmpty ? text : 'Identifique a partir da imagem'}
        ''';

        final List<Content> content = [];
        if (_imageFile != null) {
          final imageBytes = await _imageFile!.readAsBytes();
          content.add(Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes),
          ]));
        } else {
          content.add(Content.text(prompt));
        }

        final response = await model.generateContent(content);
        String responseText = response.text ?? '';
        
        final jsonMatch = RegExp(r'\[\s*\{.*\}\s*\]', dotAll: true).firstMatch(responseText);
        if (jsonMatch != null) {
          responseText = jsonMatch.group(0)!;
        } else {
          responseText = responseText.replaceAll(RegExp(r'```json|```'), '').trim();
        }

        if (responseText.isEmpty) continue;

        try {
          final List<dynamic> jsonList = jsonDecode(responseText);
          if (jsonList.isNotEmpty) {
            int count = 0;
            for (var item in jsonList) {
              if (item is Map && item.containsKey('name') && item.containsKey('calories')) {
                provider.addMeal(
                  item['name'], 
                  item['calories'],
                  protein: item['protein'] ?? 0,
                  carbs: item['carbs'] ?? 0,
                  fat: item['fat'] ?? 0,
                );
                count++;
              }
            }
            if (count > 0) {
              _controller.clear();
              setState(() => _imageFile = null);
              success = true;
              break; 
            }
          }
        } catch (e) {
          lastErrorMessage = 'Erro na resposta da IA (formato JSON inválido)';
          continue;
        }
      } catch (e) {
        lastErrorMessage = e.toString();
      }
    }

    if (!success && mounted) {
      String displayError = 'Não foi possível analisar. ';
      if (discoveredModels.isEmpty) {
        displayError += 'Nenhum modelo Gemini encontrado. ($discoveryError)';
      } else {
        displayError += 'Erro: $lastErrorMessage';
      }
      setState(() => _error = displayError);
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              if (_imageFile != null && !_loading)
                TextButton.icon(
                  onPressed: () => setState(() => _imageFile = null),
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  label: const Text('Remover Foto', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Column(
              children: [
                Skeleton(height: 60, borderRadius: 12),
                SizedBox(height: 12),
                Skeleton(height: 48, borderRadius: 8),
              ],
            )
          else ...[
            if (_imageFile != null)
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(_imageFile!.path)),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
              ),
            TextField(
              controller: _controller,
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                hintText: _imageFile != null 
                  ? 'Descreva detalhes (opcional)...' 
                  : 'Ex: 2 ovos fritos, 1 pão francês...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.indigo),
                ),
                IconButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, color: Colors.indigo),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: (_loading || (_controller.text.isEmpty && _imageFile == null)) ? null : _analyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.send, size: 20),
                  label: const Text('Analisar'),
                ),
              ],
            ),
          ],
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
