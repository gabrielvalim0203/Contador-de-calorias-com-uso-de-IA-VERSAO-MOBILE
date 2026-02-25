import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterProvider with ChangeNotifier {
  Map<String, int> _waterLogs = {}; // Date (yyyy-MM-dd) -> Total mL
  int _dailyGoal = 2000; // mL
  int _glassSize = 250; // mL

  Map<String, int> get waterLogs => _waterLogs;
  int get dailyGoal => _dailyGoal;
  int get glassSize => _glassSize;

  WaterProvider() {
    _loadFromPrefs();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  int getWaterForDate(DateTime date) {
    return _waterLogs[_formatDate(date)] ?? 0;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString('water_logs');
    if (logsJson != null) {
      _waterLogs = Map<String, int>.from(jsonDecode(logsJson));
    }
    _dailyGoal = prefs.getInt('water_goal') ?? 2000;
    _glassSize = prefs.getInt('water_glass_size') ?? 250;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('water_logs', jsonEncode(_waterLogs));
    prefs.setInt('water_goal', _dailyGoal);
    prefs.setInt('water_glass_size', _glassSize);
  }

  void addWater(DateTime date, {int? amount}) {
    final dateKey = _formatDate(date);
    final current = _waterLogs[dateKey] ?? 0;
    _waterLogs[dateKey] = current + (amount ?? _glassSize);
    _saveToPrefs();
    notifyListeners();
  }

  void removeWater(DateTime date, {int? amount}) {
    final dateKey = _formatDate(date);
    final current = _waterLogs[dateKey] ?? 0;
    final toRemove = amount ?? _glassSize;
    if (current >= toRemove) {
      _waterLogs[dateKey] = current - toRemove;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void setGoal(int goal) {
    _dailyGoal = goal;
    _saveToPrefs();
    notifyListeners();
  }
}
