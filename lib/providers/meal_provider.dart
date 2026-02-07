import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Meal {
  final String id;
  final String name;
  final int calories;
  final DateTime date;

  Meal({required this.id, required this.name, required this.calories, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'date': date.toIso8601String(),
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'],
        name: json['name'],
        calories: json['calories'],
        date: DateTime.parse(json['date']),
      );
}

class HistoryItem {
  final String id;
  final String name;
  final int calories;

  HistoryItem({required this.id, required this.name, required this.calories});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'calories': calories};

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'],
        name: json['name'],
        calories: json['calories'],
      );
}

class MealProvider with ChangeNotifier {
  List<Meal> _meals = [];
  List<HistoryItem> _history = [];
  int _goal = 2000;
  String _apiKey = '';
  
  // OPCIONAL: Coloque sua chave aqui para ela já vir configurada!
  // (Lembre-se de apagar antes de subir para o GitHub!)
  static const String _hardcodedApiKey = ''; 

  DateTime _selectedDate = DateTime.now();

  List<Meal> get meals => _meals;
  List<HistoryItem> get history => _history;
  int get goal => _goal;
  String get apiKey => _apiKey;
  DateTime get selectedDate => _selectedDate;

  List<Meal> get currentMeals {
    return _meals.where((meal) {
      return meal.date.year == _selectedDate.year &&
          meal.date.month == _selectedDate.month &&
          meal.date.day == _selectedDate.day;
    }).toList();
  }

  int get totalCalories => currentMeals.fold(0, (sum, item) => sum + item.calories);

  MealProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Meals
    final mealsJson = prefs.getString('meals');
    if (mealsJson != null) {
      final List<dynamic> decoded = jsonDecode(mealsJson);
      _meals = decoded.map((item) => Meal.fromJson(item)).toList();
    }

    // Load History
    final historyJson = prefs.getString('history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _history = decoded.map((item) => HistoryItem.fromJson(item)).toList();
    }

    // Load Goal
    _goal = prefs.getInt('goal') ?? 2000;

    // Load API Key
    _apiKey = prefs.getString('apiKey') ?? _hardcodedApiKey;

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('meals', jsonEncode(_meals.map((e) => e.toJson()).toList()));
    prefs.setString('history', jsonEncode(_history.map((e) => e.toJson()).toList()));
    prefs.setInt('goal', _goal);
    prefs.setString('apiKey', _apiKey);
  }

  void addMeal(String name, int calories) {
    final newMeal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      calories: calories,
      date: _selectedDate,
    );

    _meals.insert(0, newMeal);
    
    // Add to history if unique
    final exists = _history.any((h) => h.name.toLowerCase() == name.toLowerCase() && h.calories == calories);
    if (!exists) {
      _history.insert(0, HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        calories: calories,
      ));
    }

    _saveToPrefs();
    notifyListeners();
  }

  void removeMeal(String id) {
    _meals.removeWhere((m) => m.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void updateMeal(String id, String name, int calories) {
    final index = _meals.indexWhere((m) => m.id == id);
    if (index != -1) {
      final oldMeal = _meals[index];
      _meals[index] = Meal(
        id: oldMeal.id,
        name: name,
        calories: calories,
        date: oldMeal.date,
      );
      _saveToPrefs();
      notifyListeners();
    }
  }


  void setGoal(int newGoal) {
    _goal = newGoal;
    _saveToPrefs();
    notifyListeners();
  }

  void setApiKey(String key) {
    _apiKey = key;
    _saveToPrefs();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void completeDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }
}
