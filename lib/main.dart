import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const KmIndustrialApp());
}

class KmIndustrialApp extends StatelessWidget {
  const KmIndustrialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KmIndustrial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2DBE4A)),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2DBE4A),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
