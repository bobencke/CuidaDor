import 'package:flutter/material.dart';

import '../models/pain_assessment_request.dart';
import '../services/pain_assessment_service.dart';
import 'home_screen.dart';

class PainAssessmentScreen extends StatefulWidget {
  final String token;

  const PainAssessmentScreen({super.key, required this.token});

  @override
  State<PainAssessmentScreen> createState() => _PainAssessmentScreenState();
}

class _PainAssessmentScreenState extends State<PainAssessmentScreen> {
  int _usualPain = 3;
  int _localizedPain = 3;
  int _mood = 3;
  int _sleep = 3;

  bool _limitsActivities = false;
  bool _worseWithMovement = false;
  bool _usesMedication = false;
  bool _usesNonDrug = false;

  final _notesController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  final _service = PainAssessmentService();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final req = PainAssessmentRequest(
        usualPain: _usualPain,
        localizedPain: _localizedPain,
        moodToday: _mood,
        sleepQuality: _sleep,
        limitsPhysicalActivities: _limitsActivities,
        painWorseWithMovement: _worseWithMovement,
        usesPainMedication: _usesMedication,
        usesNonDrugPainRelief: _usesNonDrug,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _service.createAssessment(widget.token, req);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(token: widget.token),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildFaceRow(
      {required String title,
      required int value,
      required ValueChanged<int> onChanged}) {
    const faces = [
      '😃',
      '🙂',
      '😐',
      '🙁',
      '😣',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final selected = value == index + 1;
                return GestureDetector(
                  onTap: () => onChanged(index + 1),
                  child: Column(
                    children: [
                      Text(
                        faces[index],
                        style: TextStyle(
                          fontSize: selected ? 32 : 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${index + 1}',
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          )),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E7C8A);
    const backgroundColor = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Avaliação da Dor'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'De 1 a 5 qual sua dor normalmente?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Slider(
                        value: _usualPain.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '$_usualPain',
                        onChanged: (v) =>
                            setState(() => _usualPain = v.toInt()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('1'),
                          Text('5'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildFaceRow(
                title: 'Registro de dor localizada hoje',
                value: _localizedPain,
                onChanged: (v) => setState(() => _localizedPain = v),
              ),
              _buildFaceRow(
                title: 'Humor hoje',
                value: _mood,
                onChanged: (v) => setState(() => _mood = v),
              ),
              _buildFaceRow(
                title: 'Qualidade de sono hoje',
                value: _sleep,
                onChanged: (v) => setState(() => _sleep = v),
              ),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Questionário',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('A dor limita as atividades físicas?'),
                        value: _limitsActivities,
                        onChanged: (v) =>
                            setState(() => _limitsActivities = v),
                      ),
                      SwitchListTile(
                        title: const Text('A dor piora com o movimento?'),
                        value: _worseWithMovement,
                        onChanged: (v) =>
                            setState(() => _worseWithMovement = v),
                      ),
                      SwitchListTile(
                        title: const Text('Você usa medicação para dor?'),
                        value: _usesMedication,
                        onChanged: (v) =>
                            setState(() => _usesMedication = v),
                      ),
                      SwitchListTile(
                        title: const Text(
                            'Você usa alguma técnica não medicamentosa para dor?'),
                        value: _usesNonDrug,
                        onChanged: (v) =>
                            setState(() => _usesNonDrug = v),
                      ),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Observações (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}