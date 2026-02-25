class UserProfile {
  final int age;
  final double weight;
  final double height;
  final String gender; // 'Masculino' or 'Feminino'
  final double activityLevel;
  final bool useAutoGoal;

  UserProfile({
    this.age = 25,
    this.weight = 70.0,
    this.height = 170.0,
    this.gender = 'Masculino',
    this.activityLevel = 1.2,
    this.useAutoGoal = false,
  });

  int get calculatedTDEE {
    double tmb;
    if (gender == 'Masculino') {
      tmb = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      tmb = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    return (tmb * activityLevel).round();
  }

  Map<String, dynamic> toJson() => {
    'age': age,
    'weight': weight,
    'height': height,
    'gender': gender,
    'activityLevel': activityLevel,
    'useAutoGoal': useAutoGoal,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    age: json['age'] ?? 25,
    weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
    height: (json['height'] as num?)?.toDouble() ?? 170.0,
    gender: json['gender'] ?? 'Masculino',
    activityLevel: (json['activityLevel'] as num?)?.toDouble() ?? 1.2,
    useAutoGoal: json['useAutoGoal'] ?? false,
  );
}
