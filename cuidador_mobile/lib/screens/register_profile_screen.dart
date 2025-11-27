import 'package:flutter/material.dart';

import '../models/auth_response.dart';
import '../models/register_request.dart';
import '../models/update_user_profile_request.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'pain_assessment_screen.dart';

class RegisterProfileScreen extends StatefulWidget {
  final String? token;
  final bool isEditing;

  const RegisterProfileScreen({
    super.key,
    this.token,
    this.isEditing = false,
  });

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
  final _newComorbidityController = TextEditingController();

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
  bool _isLoadingProfile = false;
  String? _errorMessage;

  final _authService = AuthService();
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && (widget.token ?? '').isNotEmpty) {
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _newComorbidityController.dispose();
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

  Future<void> _loadProfile() async {
    if (widget.token == null || widget.token!.isEmpty) return;

    setState(() {
      _isLoadingProfile = true;
      _errorMessage = null;
    });

    try {
      final profile = await _userService.getProfile(widget.token!);

      if (!mounted) return;
      setState(() {
        _nameController.text = profile.fullName;
        _ageController.text =
            profile.age != null ? profile.age.toString() : '';
        _sex = profile.sex ?? _sex;
        _phoneController.text = profile.phoneNumber ?? '';
        _emailController.text = profile.email;

        _selectedComorbidities
          ..clear()
          ..addAll(profile.comorbidities);

        for (final c in profile.comorbidities) {
          if (!_allComorbidities.contains(c)) {
            _allComorbidities.add(c);
          }
        }

        if (profile.accessibility != null) {
          _fontScale = profile.accessibility!.fontScale;
          _highContrast = profile.accessibility!.highContrast;
          _voiceReading = profile.accessibility!.voiceReading;
        }

        if (profile.consent != null) {
          _consentLgpd = profile.consent!.accepted;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
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
      if (widget.isEditing && (widget.token ?? '').isNotEmpty) {
        // --------- MODO EDIÇÃO: chama PUT /api/Users/me ----------------
        final req = UpdateUserProfileRequest(
          fullName: _nameController.text.trim(),
          age: _ageController.text.trim().isEmpty
              ? null
              : int.tryParse(_ageController.text.trim()),
          sex: _sex,
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          comorbidities: _selectedComorbidities.toList(),
          fontScale: _fontScale,
          highContrast: _highContrast,
          voiceReading: _voiceReading,
          acceptLgpd: _consentLgpd,
        );

        await _userService.updateProfile(widget.token!, req);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } else {
        // --------- MODO CADASTRO: registra usuário e vai pra Avaliação da Dor
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
      }
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
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
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
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nome*',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Informe o nome'
                                    : null,
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
                                        final n = int.tryParse(v);
                                        if (n == null || n <= 0) {
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
                                          child: Text('Feminino'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Masculino',
                                          child: Text('Masculino'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Outro',
                                          child: Text('Outro'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => _sex = value);
                                        }
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
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      decoration: const InputDecoration(
                                        labelText: 'Contato',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emailController,
                                      enabled: !widget.isEditing,
                                      decoration: const InputDecoration(
                                        labelText: 'Email*',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      validator: (v) {
                                        if (widget.isEditing) return null;
                                        if (v == null || v.isEmpty) {
                                          return 'Informe o email';
                                        }
                                        if (!v.contains('@')) {
                                          return 'Email inválido';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (!widget.isEditing) ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Senha*',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  validator: (v) {
                                    if (widget.isEditing) return null;
                                    if (v == null || v.isEmpty) {
                                      return 'Informe a senha';
                                    }
                                    if (v.length < 6) {
                                      return 'Mínimo 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Diagnóstico e comorbidades (Quais?)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _allComorbidities
                                  .map(
                                    (c) => FilterChip(
                                      label: Text(c),
                                      selected:
                                          _selectedComorbidities.contains(c),
                                      onSelected: (_) => _toggleComorbidity(c),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _newComorbidityController,
                                    decoration: const InputDecoration(
                                      labelText: 'Adicionar comorbidade',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    final text = _newComorbidityController.text
                                        .trim();
                                    if (text.isEmpty) return;
                                    setState(() {
                                      if (!_allComorbidities.contains(text)) {
                                        _allComorbidities.add(text);
                                      }
                                      _selectedComorbidities.add(text);
                                    });
                                    _newComorbidityController.clear();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('+ Adicionar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Preferências de acessibilidade',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Tamanho da fonte'),
                                Expanded(
                                  child: Slider(
                                    min: 0.5,
                                    max: 2.0,
                                    divisions: 15,
                                    value: _fontScale,
                                    onChanged: (v) {
                                      setState(() => _fontScale = v);
                                    },
                                  ),
                                ),
                                const Text('Aa'),
                              ],
                            ),
                            SwitchListTile(
                              title: const Text('Alto contraste'),
                              value: _highContrast,
                              onChanged: (v) {
                                setState(() => _highContrast = v);
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Leitura por voz'),
                              value: _voiceReading,
                              onChanged: (v) {
                                setState(() => _voiceReading = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Consentimento para uso de dados (LGPD)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              value: _consentLgpd,
                              onChanged: (v) {
                                setState(() => _consentLgpd = v ?? false);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text(
                                'Li e concordo com a coleta e uso dos meus dados '
                                'conforme a LGPD.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
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