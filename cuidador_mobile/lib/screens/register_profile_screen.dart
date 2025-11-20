import 'package:flutter/material.dart';

import '../models/auth_response.dart';
import '../models/register_request.dart';
import '../services/auth_service.dart';
import 'pain_assessment_screen.dart';

class RegisterProfileScreen extends StatefulWidget {
  const RegisterProfileScreen({super.key});

  @override
  State<RegisterProfileScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _sex = 'Feminino';
  double _fontScale = 1.0;
  bool _highContrast = false;
  bool _voiceReading = false;
  bool _consentLgpd = false;

  final List<String> _allComorbidities = [
    'Artrite',
    'Doenças reumáticas',
    'Doença pulmonar',
    'Hipertensão arterial',
  ];
  final Set<String> _selectedComorbidities = {};

  bool _isSaving = false;
  String? _errorMessage;

  final _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleComorbidity(String c) {
    setState(() {
      if (_selectedComorbidities.contains(c)) {
        _selectedComorbidities.remove(c);
      } else {
        _selectedComorbidities.add(c);
      }
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_consentLgpd) {
      setState(() {
        _errorMessage = 'Você precisa aceitar o uso de dados (LGPD).';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final req = RegisterRequest(
        fullName: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        sex: _sex,
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        comorbidities: _selectedComorbidities.toList(),
        fontScale: _fontScale,
        highContrast: _highContrast,
        voiceReading: _voiceReading,
        consentLgpd: _consentLgpd,
      );

      final AuthResponse auth = await _authService.register(req);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PainAssessmentScreen(token: auth.token),
        ),
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

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFE0E0E0);
    const primaryColor = Color(0xFF2E7C8A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Cadastro e Perfil'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Cadastro Básico',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome*',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Informe o nome' : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Idade*',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Informe a idade';
                                  }
                                  if (int.tryParse(v) == null) {
                                    return 'Idade inválida';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _sex,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Feminino',
                                      child: Text('Feminino')),
                                  DropdownMenuItem(
                                      value: 'Masculino',
                                      child: Text('Masculino')),
                                  DropdownMenuItem(
                                      value: 'Outro', child: Text('Outro')),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _sex = v);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Sexo*',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Contato*',
                            hintText: '(99) 99999-9999',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Informe o contato' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email*',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Informe o email';
                            }
                            if (!v.contains('@')) return 'Email inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Senha*',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Informe a senha' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Diagnóstico e comorbidades',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _allComorbidities
                            .map(
                              (c) => FilterChip(
                                label: Text(c),
                                selected: _selectedComorbidities.contains(c),
                                onSelected: (_) => _toggleComorbidity(c),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Preferências de acessibilidade',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Row(
                        children: [
                          const Text('Tamanho da fonte'),
                          Expanded(
                            child: Slider(
                              value: _fontScale,
                              min: 0.8,
                              max: 1.4,
                              divisions: 6,
                              label: _fontScale.toStringAsFixed(1),
                              onChanged: (v) =>
                                  setState(() => _fontScale = v),
                            ),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        title: const Text('Alto contraste'),
                        value: _highContrast,
                        onChanged: (v) =>
                            setState(() => _highContrast = v),
                      ),
                      SwitchListTile(
                        title: const Text('Leitura por voz'),
                        value: _voiceReading,
                        onChanged: (v) =>
                            setState(() => _voiceReading = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: _consentLgpd,
                        onChanged: (v) =>
                            setState(() => _consentLgpd = v ?? false),
                        title: const Text(
                            'Li e concordo com a coleta e uso dos meus dados conforme a LGPD'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
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
                                          AlwaysStoppedAnimation(Colors.white)),
                                )
                              : const Text('Salvar'),
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