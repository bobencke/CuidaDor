import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/auth_response.dart';
import '../models/register_request.dart';
import '../models/update_user_profile_request.dart';
import '../models/user_data_export.dart';
import '../services/auth_service.dart';
import '../services/reports_service.dart';
import '../services/user_service.dart';
import '../widgets/accessibility_wrapper.dart';
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

enum _ExportOption { me, all }

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
  bool _isExporting = false;
  String? _errorMessage;

  final _authService = AuthService();
  final _userService = UserService();
  final _reportsService = ReportsService();
  final _accessibilityController = AccessibilityController.instance;

  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();

    _tts.setLanguage('pt-BR');
    _tts.setSpeechRate(0.5);
    _fontScale = _accessibilityController.fontScale;
    _highContrast = _accessibilityController.highContrast;

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
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (!_voiceReading) return;
    await _tts.stop();
    await _tts.speak(text);
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
      _applyAccessibilityPreferences();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _errorMessage = msg;
      });
      _speak(msg);
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  void _applyAccessibilityPreferences() {
    _accessibilityController.updatePreferences(
      fontScale: _fontScale,
      highContrast: _highContrast,
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_consentLgpd) {
      const msg = 'Você precisa aceitar o uso de dados (LGPD).';
      setState(() {
        _errorMessage = msg;
      });
      _speak(msg);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (widget.isEditing && (widget.token ?? '').isNotEmpty) {
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
        const msg = 'Perfil atualizado com sucesso!';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(msg)),
        );
        _speak(msg);
        _applyAccessibilityPreferences();
      } else {
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
        _applyAccessibilityPreferences();
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _errorMessage = msg;
      });
      _speak(msg);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // EXPORTAÇÃO EM CSV

  Future<void> _exportUserData({required bool allUsers}) async {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      const msg = 'Você precisa estar logado para exportar os dados.';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(msg),
        ),
      );
      _speak(msg);
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      List<UserDataExport> exports;

      if (allUsers) {
        exports = await _reportsService.getAllUsersDataExport(token);
      } else {
        final single = await _reportsService.getUserDataExport(token);
        exports = [single];
      }

      if (exports.isEmpty) {
        if (!mounted) return;
        const msg = 'Não há dados para exportar.';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(msg)),
        );
        _speak(msg);
        return;
      }

      // Construção do CSV
      final buffer = StringBuffer();
      for (var i = 0; i < exports.length; i++) {
        final data = exports[i];

        if (i > 0) {
          buffer.writeln();
          buffer.writeln();
        }

        buffer.writeln(
            '===== USUARIO ${i + 1} - ${_escapeCsv(data.user.fullName)} =====');
        buffer.write(_buildCsvForUser(data));
      }

      final csv = buffer.toString();

      final dir = await getTemporaryDirectory();
      final fileName = allUsers
          ? 'cuidador_export_todos_${DateTime.now().millisecondsSinceEpoch}.csv'
          : 'cuidador_export_meus_dados_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csv, encoding: utf8);

      final emailTo = _emailController.text.trim();
      final subject = allUsers
          ? 'Exportação de dados - Todos os usuários'
          : 'Exportação de dados - Meus dados';
      final body = emailTo.isNotEmpty
          ? 'Sugestão: envie este arquivo CSV para o e-mail $emailTo a partir do app de e-mail da sua escolha.'
          : 'Segue o arquivo CSV com os dados exportados.';

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject,
        text: body,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = 'Erro ao exportar dados: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      _speak(msg);
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _buildCsvForUser(UserDataExport data) {
    final b = StringBuffer();

    // Seção usuário
    b.writeln('SECAO,CAMPO,VALOR');
    b.writeln('Usuario,Id,${data.user.id}');
    b.writeln('Usuario,Nome,${_escapeCsv(data.user.fullName)}');
    b.writeln('Usuario,Email,${_escapeCsv(data.user.email)}');
    if (data.user.age != null) {
      b.writeln('Usuario,Idade,${data.user.age}');
    }
    if (data.user.sex != null) {
      b.writeln('Usuario,Sexo,${_escapeCsv(data.user.sex!)}');
    }

    // Comorbidades
    if (data.comorbidities.isNotEmpty) {
      b.writeln();
      b.writeln('Comorbidades');
      b.writeln('UserId,Nome');
      for (final c in data.comorbidities) {
        b.writeln('${c.userId},${_escapeCsv(c.name)}');
      }
    }

    // Avaliações de dor
    if (data.painAssessments.isNotEmpty) {
      b.writeln();
      b.writeln('AvaliacaoDeDor');
      b.writeln(
        'Id,UserId,Date,UsualPain,LocalizedPain,MoodToday,SleepQuality,'
        'LimitsPhysicalActivities,PainWorseWithMovement,UsesPainMedication,'
        'UsesNonDrugPainRelief,Notes',
      );
      for (final p in data.painAssessments) {
        b.writeln([
          p.id,
          p.userId,
          p.date.toIso8601String(),
          p.usualPain,
          p.localizedPain,
          p.moodToday,
          p.sleepQuality,
          p.limitsPhysicalActivities,
          p.painWorseWithMovement,
          p.usesPainMedication,
          p.usesNonDrugPainRelief,
          _escapeCsv(p.notes),
        ].join(','));
      }
    }

    // Sessões de técnica
    if (data.techniqueSessions.isNotEmpty) {
      b.writeln();
      b.writeln('SessoesTecnica');
      b.writeln(
        'Id,UserId,ReliefTechniqueId,StartedAt,FinishedAt,ResultFeeling,Notes',
      );
      for (final s in data.techniqueSessions) {
        b.writeln([
          s.id,
          s.userId,
          s.reliefTechniqueId,
          s.startedAt.toIso8601String(),
          s.finishedAt.toIso8601String(),
          s.resultFeeling,
          _escapeCsv(s.notes),
        ].join(','));
      }
    }

    // Feedback geral
    if (data.generalFeedbacks.isNotEmpty) {
      b.writeln();
      b.writeln('FeedbackGeral');
      b.writeln('Id,UserId,CreatedAt,GeneralFeeling,Text');
      for (final f in data.generalFeedbacks) {
        b.writeln([
          f.id,
          f.userId,
          f.createdAt.toIso8601String(),
          f.generalFeeling ?? '',
          _escapeCsv(f.text),
        ].join(','));
      }
    }

    return b.toString();
  }

  String _escapeCsv(String? value) {
    if (value == null) return '';
    var v = value.replaceAll('"', '""');
    if (v.contains(',') || v.contains('\n') || v.contains(';')) {
      v = '"$v"';
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return AccessibilityWrapper(
      token: widget.token,
      child: Builder(
        builder: (context) {
          final palette = AccessibilityScope.of(context).palette;

          return Scaffold(
            backgroundColor: palette.backgroundColor,
            appBar: AppBar(
              backgroundColor: palette.backgroundColor,
              elevation: 0,
              title: const Text('Cadastro e Perfil'),
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
                                          selected: _selectedComorbidities
                                              .contains(c),
                                          onSelected: (_) =>
                                              _toggleComorbidity(c),
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
                                    TextButton(
                                      onPressed: () {
                                        final text =
                                            _newComorbidityController.text
                                                .trim();
                                        if (text.isEmpty) return;
                                        setState(() {
                                          if (!_allComorbidities
                                              .contains(text)) {
                                            _allComorbidities.add(text);
                                          }
                                          _selectedComorbidities.add(text);
                                        });
                                        _newComorbidityController.clear();
                                      },
                                      child: const Text('+ Adicionar'),
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
                                          _applyAccessibilityPreferences();
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
                                    _applyAccessibilityPreferences();
                                  },
                                ),
                                SwitchListTile(
                                  title: const Text('Leitura por voz'),
                                  value: _voiceReading,
                                  onChanged: (v) async {
                                    setState(() => _voiceReading = v);
                                    if (v) {
                                      await _speak(
                                        'Leitura por voz ativada. O aplicativo poderá ler mensagens importantes para você.',
                                      );
                                    }
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
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
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
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _onSave,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text('Salvar'),
                              ),
                            ),
                            if (widget.token != null &&
                                widget.token!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              PopupMenuButton<_ExportOption>(
                                onSelected: (option) {
                                  if (option == _ExportOption.me) {
                                    _exportUserData(allUsers: false);
                                  } else {
                                    _exportUserData(allUsers: true);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: _ExportOption.me,
                                    child: Text('Exportar meus dados'),
                                  ),
                                  PopupMenuItem(
                                    value: _ExportOption.all,
                                    child: Text(
                                      'Exportar dados de todos usuários',
                                    ),
                                  ),
                                ],
                                icon: _isExporting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.more_vert),
                              ),
                            ],
                          ],
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
