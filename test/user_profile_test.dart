import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_tracker_mobile/models/user_profile.dart';

void main() {
  group('UserProfile Tests', () {
    test('TDEE Calculation - Male', () {
      final profile = UserProfile(
        age: 25,
        weight: 70,
        height: 175,
        gender: 'Masculino',
        activityLevel: 1.2,
      );
      
      // (10 * 70) + (6.25 * 175) - (5 * 25) + 5 = 700 + 1093.75 - 125 + 5 = 1673.75
      // 1673.75 * 1.2 = 2008.5 -> round to 2009
      expect(profile.calculatedTDEE, 2009);
    });

    test('TDEE Calculation - Female', () {
      final profile = UserProfile(
        age: 30,
        weight: 60,
        height: 165,
        gender: 'Feminino',
        activityLevel: 1.375,
      );
      
      // (10 * 60) + (6.25 * 165) - (5 * 30) - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
      // 1320.25 * 1.375 = 1815.34 -> round to 1815
      expect(profile.calculatedTDEE, 1815);
    });
  });
}
