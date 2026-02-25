import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';
import '../models/history_item.dart';

class MealProvider with ChangeNotifier {
  List<Meal> _meals = [];
  List<HistoryItem> _history = [];
  int _goal = 2000;
  String _apiKey = EnvConfig.geminiApiKey;
  UserProfile _profile = UserProfile();
  
  DateTime _selectedDate = DateTime.now();

  List<Meal> get meals => _meals;
  List<HistoryItem> get history => _history;
  String get apiKey => _apiKey;
  DateTime get selectedDate => _selectedDate;
  UserProfile get profile => _profile;

  int get goal {
    if (_profile.useAutoGoal) {
      return _profile.calculatedTDEE;
    }
    return _goal;
  }

  List<Meal> get currentMeals {
    return _meals.where((meal) {
      return meal.date.year == _selectedDate.year &&
          meal.date.month == _selectedDate.month &&
          meal.date.day == _selectedDate.day;
    }).toList();
  }

  int get totalCalories => currentMeals.fold(0, (sum, item) => sum + item.calories);
  int get totalProtein => currentMeals.fold(0, (sum, item) => sum + item.protein);
  int get totalCarbs => currentMeals.fold(0, (sum, item) => sum + item.carbs);
  int get totalFat => currentMeals.fold(0, (sum, item) => sum + item.fat);

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
    _apiKey = prefs.getString('apiKey') ?? EnvConfig.geminiApiKey;

    // Load Profile
    final profileJson = prefs.getString('userProfile');
    if (profileJson != null) {
      _profile = UserProfile.fromJson(jsonDecode(profileJson));
    }

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('meals', jsonEncode(_meals.map((e) => e.toJson()).toList()));
    prefs.setString('history', jsonEncode(_history.map((e) => e.toJson()).toList()));
    prefs.setInt('goal', _goal);
    prefs.setString('apiKey', _apiKey);
    prefs.setString('userProfile', jsonEncode(_profile.toJson()));
  }

  void addMeal(String name, int calories, {int protein = 0, int carbs = 0, int fat = 0}) {
    final newMeal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      calories: calories,
      date: _selectedDate,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    _meals.insert(0, newMeal);
    
    // Add to history if unique
    final exists = _history.any((h) => 
      h.name.toLowerCase() == name.toLowerCase() && 
      h.calories == calories &&
      h.protein == protein &&
      h.carbs == carbs &&
      h.fat == fat
    );
    
    if (!exists) {
      _history.insert(0, HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
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

  void updateMeal(String id, String name, int calories, {int protein = 0, int carbs = 0, int fat = 0}) {
    final index = _meals.indexWhere((m) => m.id == id);
    if (index != -1) {
      final oldMeal = _meals[index];
      _meals[index] = Meal(
        id: oldMeal.id,
        name: name,
        calories: calories,
        date: oldMeal.date,
        protein: protein,
        carbs: carbs,
        fat: fat,
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

  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
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

