import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

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

  int? _generalFeeling;
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
    if (_generalFeeling == null && _feedbackController.text.trim().isEmpty) {
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

  Widget _buildEvolutionCard() {
    if (_report == null || _report!.evolution.isEmpty) {
      return const Text(
        'Ainda não há dados suficientes. '
        'Registre suas dores diariamente para acompanhar sua evolução.',
        style: TextStyle(fontSize: 12, color: Colors.black54),
      );
    }

    final points = _report!.evolution;

    final sortedPoints = [...points]
      ..sort((a, b) => a.date.compareTo(b.date));

    final List<Map<String, dynamic>> chartData = sortedPoints
        .map((p) => {
              'date': p.date,          // eixo X
              'value': p.averagePain,  // eixo Y
            })
        .toList();

    final varset = graphic.Varset('date') * graphic.Varset('value');

    return SizedBox(
      height: 220,
      child: graphic.Chart(
        data: chartData,
        variables: {
          'date': graphic.Variable(
            accessor: (Map map) => map['date'] as DateTime,
            scale: graphic.TimeScale(
              formatter: (dt) => '${dt.day}/${dt.month}',
            ),
          ),
          'value': graphic.Variable(
            accessor: (Map map) => map['value'] as num,
            scale: graphic.LinearScale(min: 0, max: 5),
          ),
        },
        marks: [
          graphic.LineMark(
            position: varset,
            shape: graphic.ShapeEncode(
              value: graphic.BasicLineShape(smooth: true),
            ),
            color: graphic.ColorEncode(value: Colors.teal),
            size: graphic.SizeEncode(value: 2),
          ),

          graphic.AreaMark(
            position: varset,
            shape: graphic.ShapeEncode(
              value: graphic.BasicAreaShape(smooth: true),
            ),
            color: graphic.ColorEncode(
              value: Colors.teal.withOpacity(0.15),
            ),
          ),
        ],
        axes: [
          graphic.Defaults.horizontalAxis,
          graphic.Defaults.verticalAxis,
        ],
      ),
    );
  }

  String _buildEvolutionMessage() {
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

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFE0E0E0);
    const primaryColor = Color(0xFF2E7C8A);

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
                                _buildEvolutionCard(),
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
                                    _buildEvolutionMessage(),
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