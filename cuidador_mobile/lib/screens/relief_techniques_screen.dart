import 'package:flutter/material.dart';

import '../models/relief_technique.dart';
import '../services/relief_technique_service.dart';
import 'technique_detail_screen.dart';

class ReliefTechniquesScreen extends StatefulWidget {
  final String token;

  const ReliefTechniquesScreen({super.key, required this.token});

  @override
  State<ReliefTechniquesScreen> createState() => _ReliefTechniquesScreenState();
}

class _ReliefTechniquesScreenState extends State<ReliefTechniquesScreen> {
  final _service = ReliefTechniqueService();

  bool _isLoading = true;
  String? _error;
  List<ReliefTechniqueListItem> _techniques = [];

  @override
  void initState() {
    super.initState();
    _loadTechniques();
  }

  Future<void> _loadTechniques() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _service.getTechniques(widget.token);
      if (!mounted) return;
      setState(() => _techniques = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFE0E0E0);
    const primaryColor = Color(0xFF2E7C8A);

    Widget buildTechniqueCard(ReliefTechniqueListItem tech) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TechniqueDetailScreen(
                  token: widget.token,
                  techniqueId: tech.id,
                ),
              ),
            );
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
                        tech.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tech.shortDescription,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      if (tech.warningText != null &&
                          tech.warningText!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tech.warningText!,
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
                            onPressed: _loadTechniques,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _techniques.length,
                    itemBuilder: (context, index) =>
                        buildTechniqueCard(_techniques[index]),
                  ),
      ),
    );
  }
}