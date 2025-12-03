import 'package:flutter/material.dart';

import '../models/relief_technique.dart';
import '../models/technique_session_request.dart';
import '../services/relief_technique_service.dart';

class TechniqueDetailScreen extends StatefulWidget {
  final String token;
  final int techniqueId;

  const TechniqueDetailScreen({
    super.key,
    required this.token,
    required this.techniqueId,
  });

  @override
  State<TechniqueDetailScreen> createState() => _TechniqueDetailScreenState();
}

class _TechniqueDetailScreenState extends State<TechniqueDetailScreen> {
  final _service = ReliefTechniqueService();
  final _notesController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  ReliefTechniqueDetail? _detail;

  late DateTime _startedAt;
  int? _selectedFeeling;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _loadDetail();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final d =
          await _service.getTechniqueDetail(widget.token, widget.techniqueId);
      if (!mounted) return;
      setState(() => _detail = d);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _finalizar() async {
    if (_detail == null) return;
    if (_selectedFeeling == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione como você se sente agora.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final req = TechniqueSessionRequest(
        reliefTechniqueId: _detail!.id,
        startedAt: _startedAt,
        finishedAt: DateTime.now(),
        resultFeeling: _selectedFeeling!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _service.registerSession(widget.token, req);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFE0E0E0);
    const primaryColor = Color(0xFF2E7C8A);

    Widget buildFace({
      required IconData icon,
      required String label,
      required Color color,
      required int value,
    }) {
      final selected = _selectedFeeling == value;

      return Expanded(
        child: InkWell(
          onTap: () {
            setState(() => _selectedFeeling = value);
          },
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.all(selected ? 3 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(color: color, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: selected
                      ? color.withOpacity(0.3)
                      : color.withOpacity(0.15),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
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



    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(_detail?.name ?? 'Técnica'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
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
                            onPressed: _loadDetail,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _detail!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _detail!.shortDescription,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Passo a passo:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._detail!.steps.map(
                                  (step) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${step.order}. '),
                                        Expanded(
                                          child: Text(
                                            step.description,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_detail!.warningText != null &&
                                    _detail!.warningText!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.deepOrange.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.deepOrange),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.deepOrange,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _detail!.warningText!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.deepOrange,
                                              ),
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
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Como você se sente agora?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    buildFace(
                                      icon: Icons.sentiment_very_satisfied,
                                      label: 'Melhor',
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
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _notesController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    labelText: 'Anotações (opcional)',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isSaving ? null : () => _finalizar(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator
                                                .adaptive(strokeWidth: 2),
                                          )
                                        : const Text('Finalizar'),
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