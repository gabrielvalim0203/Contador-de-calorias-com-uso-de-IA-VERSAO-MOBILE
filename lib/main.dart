import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'providers/meal_provider.dart';
import 'providers/water_provider.dart';
import 'providers/weight_provider.dart';
import 'screens/main_screen.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationService = NotificationService();
  await notificationService.init();
  
  // Schedule default reminders
  await notificationService.scheduleDailyReminder(
    id: 1,
    title: 'Hora de beber água! 💧',
    body: 'Não esqueça de manter sua hidratação em dia.',
    hour: 10,
    minute: 0,
  );
  await notificationService.scheduleDailyReminder(
    id: 2,
    title: 'Registro de Refeição 🍱',
    body: 'Já registrou sua última refeição?',
    hour: 13,
    minute: 30,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => WeightProvider()),
      ],
      child: MaterialApp(
        title: 'Calorie Tracker',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        theme: ThemeData(

          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'Inter', // Default system font usually fine, but specifying keeps it clean
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
