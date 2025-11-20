import 'package:flutter/material.dart';
import 'pain_assessment_screen.dart';

class HomeScreen extends StatelessWidget {
  final String token;

  const HomeScreen({super.key, this.token = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home (em construção)'),
            const SizedBox(height: 16),
            if (token.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PainAssessmentScreen(token: token),
                    ),
                  );
                },
                child: const Text('Ir para Avaliação da Dor'),
              ),
          ],
        ),
      ),
    );
  }
}