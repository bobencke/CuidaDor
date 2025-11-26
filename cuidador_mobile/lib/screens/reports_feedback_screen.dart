import 'package:flutter/material.dart';

import '../models/general_feedback_request.dart';
import '../models/pain_report.dart';
import '../services/feedback_service.dart';
import '../services/reports_service.dart';

class ReportsFeedbackScreen extends StatefulWidget {
  final String token;

  const ReportsFeedbackScreen({super.key, required this.token});

  @override
  State<ReportsFeedbackScreen> createState() => _ReportsFeedbackScreenState();
}

class _ReportsFeedbackScreenState extends State<ReportsFeedbackScreen> {
  final _reportsService = ReportsService();
  final _feedbackService = FeedbackService();
  final TextEditingController _feedbackController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  PainReport? _report;

  int? _generalFeeling; // 1=Melhor, 2=Igual, 3=Pior
  bool _isSendingFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final report = await _reportsService.getPainReport(widget.token, days: 7);
      if (!mounted) return;
      setState(() => _report = report);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendFeedback() async {
    if (_generalFeeling == null &&
        _feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um humor ou escreva um feedback.'),
        ),
      );
      return;
    }

    setState(() => _isSendingFeedback = true);

    try {
      final req = GeneralFeedbackRequest(
        generalFeeling: _generalFeeling,
        text: _feedbackController.text.trim().isEmpty
            ? null
            : _feedbackController.text.trim(),
      );

      await _feedbackService.sendGeneralFeedback(widget.token, req);

      if (!mounted) return;
      _feedbackController.clear();
      setState(() => _generalFeeling = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obrigado pelo feedback!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSendingFeedback = false);
    }
  }

  Widget _buildFaceRow({bool selectable = true}) {
    Widget buildFace({
      required IconData icon,
      required String label,
      required Color color,
      required int value,
    }) {
      final selected = selectable && _generalFeeling == value;
      return Expanded(
        child: InkWell(
          onTap: selectable
              ? () {
                  setState(() => _generalFeeling = value);
                }
              : null,
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: selected
                    ? color.withOpacity(0.3)
                    : color.withOpacity(0.15),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        buildFace(
          icon: Icons.sentiment_very_satisfied,
          label: 'Bem',
          color: Colors.green,
          value: 1,
        ),
        buildFace(
          icon: Icons.sentiment_neutral,
          label: 'Igual',
          color: Colors.orange,
          value: 2,
        ),
        buildFace(
          icon: Icons.sentiment_very_dissatisfied,
          label: 'Pior',
          color: Colors.red,
          value: 3,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFE0E0E0);
    const primaryColor = Color(0xFF2E7C8A);

    Widget buildEvolutionCard() {
      if (_report == null || _report!.evolution.isEmpty) {
        return const Text(
          'Ainda não há dados suficientes. '
          'Registre suas dores diariamente para acompanhar sua evolução.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        );
      }

      // Aqui você pode substituir pela implementação da biblioteca `graphic`
      // utilizando a lista _report!.evolution.
      final points = _report!.evolution;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                points
                    .map((p) =>
                        '${p.date.day}/${p.date.month}: ${p.averagePain.toStringAsFixed(1)}')
                    .join('  •  '),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Substitua o bloco acima por um gráfico usando a biblioteca Graphic, '
            'usando esses mesmos pontos (data x dor média).',
            style: TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      );
    }

    String buildEvolutionMessage() {
      final pr = _report?.percentageReduction;
      if (pr != null && pr > 0) {
        return 'Você está evoluindo! Sua dor reduziu '
            '${pr.toStringAsFixed(1)}% nos últimos dias.';
      } else if (pr != null && pr < 0) {
        return 'Sua dor aumentou um pouco nos últimos dias. '
            'Converse com seu profissional de saúde se for necessário.';
      } else {
        return 'Continue registrando suas dores para acompanhar sua evolução.';
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Relatórios e Feedback'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadReport,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Acompanhe sua evolução e reflita sobre '
                            'como você se sentiu após as práticas.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Evolução da dor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                buildEvolutionCard(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.trending_down,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    buildEvolutionMessage(),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Como você geralmente sente depois das práticas?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Aqui poderia entrar um resumo futuro,
                                // por enquanto apenas exibição estática:
                                Text(
                                  'Esta seção poderá mostrar estatísticas futuras '
                                  'com base nas sessões registradas.',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Como seu corpo se sente agora '
                                  'após cuidar de você?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildFaceRow(selectable: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Você tem algo a compartilhar? '
                                  'Deixe seu feedback',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _feedbackController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Escreva aqui suas impressões, dúvidas ou sugestões...',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSendingFeedback
                                        ? null
                                        : _sendFeedback,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: _isSendingFeedback
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator
                                                .adaptive(strokeWidth: 2),
                                          )
                                        : const Text('Enviar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}