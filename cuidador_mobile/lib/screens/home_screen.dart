import 'package:flutter/material.dart';

import '../widgets/accessibility_wrapper.dart';
import 'login_screen.dart';
import 'pain_assessment_screen.dart';
import 'register_profile_screen.dart';
import 'relief_techniques_screen.dart';
import 'reports_feedback_screen.dart';

class HomeScreen extends StatelessWidget {
  final String token;

  const HomeScreen({super.key, this.token = ''});

  @override
  Widget build(BuildContext context) {
    return AccessibilityWrapper(
      token: token,
      child: Builder(
        builder: (context) {
          final palette = AccessibilityScope.of(context).palette;

          Widget buildHomeCard({
            required String title,
            required String description,
            required VoidCallback onTap,
          }) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: palette.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 13,
                                color: palette.mutedTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: palette.backgroundColor,
            appBar: AppBar(
              backgroundColor: palette.backgroundColor,
              elevation: 0,
              title: const Text('Início'),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    buildHomeCard(
                      title: 'Cadastro e Perfil',
                      description:
                          'Espaço para cadastrar dados, diagnósticos e preferências de acessibilidade com LGPD.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterProfileScreen(
                              token: token,
                              isEditing: true,
                            ),
                          ),
                        );
                      },
                    ),
                    buildHomeCard(
                      title: 'Avaliação da Dor',
                      description:
                          'Registro diário da dor com escala 1–5, visual e mapa corporal simples.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PainAssessmentScreen(token: token),
                          ),
                        );
                      },
                    ),
                    buildHomeCard(
                      title: 'Técnicas de Alívio',
                      description:
                          'Exercícios, alongamentos e respiração guiada com lembretes e orientações de segurança.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReliefTechniquesScreen(token: token),
                          ),
                        );
                      },
                    ),
                    buildHomeCard(
                      title: 'Relatórios e Feedback',
                      description:
                          'Gráficos e comparativos para acompanhar a evolução e gerar relatórios de consulta.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReportsFeedbackScreen(token: token),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primaryColor,
                          foregroundColor: palette.buttonForegroundColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Deslogar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
