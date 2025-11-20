import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
// import 'screens/register_profile_screen.dart';
// import 'screens/pain_assessment_screen.dart';

void main() {
  runApp(const CuidaDorApp());
}

class CuidaDorApp extends StatelessWidget {
  const CuidaDorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CuidaDor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: const Color(0xFF2E7C8A),
      ),
      home: const LoginScreen(),
      // rotas nomeadas se quiser usar depois
      routes: {
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}