import 'dart:convert';

class Meal {
  final String id;
  final String name;
  final int calories;
  final DateTime date;
  final int protein;
  final int carbs;
  final int fat;

  Meal({
    required this.id, 
    required this.name, 
    required this.calories, 
    required this.date,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'date': date.toIso8601String(),
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'],
        name: json['name'],
        calories: json['calories'],
        date: DateTime.parse(json['date']),
        protein: json['protein'] ?? 0,
        carbs: json['carbs'] ?? 0,
        fat: json['fat'] ?? 0,
      );
}
