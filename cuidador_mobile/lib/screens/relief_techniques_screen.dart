import 'package:flutter/material.dart';

import 'technique_detail_screen.dart';

class ReliefTechniquesScreen extends StatelessWidget {
  final String token;

  const ReliefTechniquesScreen({super.key, this.token = ''});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFE0E0E0);
    const primaryColor = Color(0xFF2E7C8A);

    final techniques = [
      _Technique(
        title: 'Respiração 4-7-8',
        subtitle: 'Respiração • Ansiedade e sono',
        warning: 'Pode dar leve tontura no início',
      ),
      _Technique(
        title: 'Respiração profunda',
        subtitle: 'Respiração • Reduz tensão e dor',
      ),
      _Technique(
        title: 'Alongamento de mãos',
        subtitle: 'Alongamentos • Rigidez matinal',
        warning: 'Pare se houver dor forte',
      ),
      const _Technique(
        title: 'Relaxamento muscular progressivo',
        subtitle: 'Relaxamento • Tensão corporal',
      ),
      const _Technique(
        title: 'Toque calmante',
        subtitle: 'Relaxamento • Conforto imediato',
      ),
      _Technique(
        title: 'Calor morno local',
        subtitle: 'Termoterapia • Rigidez e desconforto',
        warning: 'Evite pele lesionada; teste a temperatura',
      ),
    ];

    Widget buildTechniqueCard(_Technique tech) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: () {
            if (tech.title == 'Respiração 4-7-8') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TechniqueDetailScreen(
                    title: 'Respiração 4-7-8',
                    description:
                        'Técnica breve para acalmar, reduzir ansiedade e ajudar no sono.',
                    steps: const [
                      'Inspire pelo nariz contando até 4.',
                      'Segure o ar contando até 7.',
                      'Expire pela boca contando até 8.',
                      'Repita 4 ciclos completos.',
                    ],
                    safetyNote:
                        'Pare imediatamente se sentir dor forte, tontura intensa ou mal-estar.',
                  ),
                ),
              );
            } else {
              // Por enquanto, só a 4-7-8 tem tela detalhada.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${tech.title} ainda será detalhada.'),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tech.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tech.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      if (tech.warning != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          tech.warning!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Técnicas de Alívio'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: techniques.length,
          itemBuilder: (context, index) => buildTechniqueCard(techniques[index]),
        ),
      ),
    );
  }
}

class _Technique {
  final String title;
  final String subtitle;
  final String? warning;

  const _Technique({
    required this.title,
    required this.subtitle,
    this.warning,
  });
}