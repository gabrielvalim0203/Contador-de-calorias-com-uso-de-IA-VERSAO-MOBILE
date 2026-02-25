class HistoryItem {
  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  HistoryItem({
    required this.id, 
    required this.name, 
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name, 
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'],
        name: json['name'],
        calories: json['calories'],
        protein: json['protein'] ?? 0,
        carbs: json['carbs'] ?? 0,
        fat: json['fat'] ?? 0,
      );
}
