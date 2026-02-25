import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightLog {
  final DateTime date;
  final double weight;

  WeightLog({required this.date, required this.weight});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight,
  };

  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog(
    date: DateTime.parse(json['date']),
    weight: json['weight'],
  );
}

class WeightProvider with ChangeNotifier {
  List<WeightLog> _weightLogs = [];

  List<WeightLog> get weightLogs => _weightLogs;

  WeightProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString('weight_logs');
    if (logsJson != null) {
      final List<dynamic> decoded = jsonDecode(logsJson);
      _weightLogs = decoded.map((item) => WeightLog.fromJson(item)).toList();
      _weightLogs.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('weight_logs', jsonEncode(_weightLogs.map((e) => e.toJson()).toList()));
  }

  void addWeight(double weight, DateTime date) {
    // Check if we already have a log for this day
    final index = _weightLogs.indexWhere((log) => 
      log.date.year == date.year && log.date.month == date.month && log.date.day == date.day
    );

    if (index != -1) {
      _weightLogs[index] = WeightLog(date: date, weight: weight);
    } else {
      _weightLogs.add(WeightLog(date: date, weight: weight));
    }
    
    _weightLogs.sort((a, b) => b.date.compareTo(a.date));
    _saveToPrefs();
    notifyListeners();
  }

  void removeLog(DateTime date) {
    _weightLogs.removeWhere((log) => 
      log.date.year == date.year && log.date.month == date.month && log.date.day == date.day
    );
    _saveToPrefs();
    notifyListeners();
  }

  double get latestWeight => _weightLogs.isNotEmpty ? _weightLogs.first.weight : 0.0;
}
