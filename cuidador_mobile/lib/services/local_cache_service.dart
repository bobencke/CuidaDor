import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import '../models/auth_response.dart';
import '../models/general_feedback_request.dart';
import '../models/pain_assessment_request.dart';
import '../models/pain_report.dart';
import '../models/register_request.dart';
import '../models/relief_technique.dart';
import '../models/technique_session_request.dart';
import '../models/update_user_profile_request.dart';
import '../models/user_data_export.dart';
import '../models/user_profile.dart';

/// Cache local para permitir uso offline sem remover chamadas HTTP.
class LocalCacheService {
  LocalCacheService._();

  static final LocalCacheService instance = LocalCacheService._();

  static const _fileName = 'cuidador_cache.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, dynamic>> _readData() async {
    final file = await _getFile();

    if (await file.exists()) {
      try {
        final raw = await file.readAsString();
        final data = jsonDecode(raw);
        if (data is Map<String, dynamic>) {
          _ensureSeeds(data);
          return data;
        }
      } catch (_) {}
    }

    final data = _seedData();
    await _writeData(data);
    return data;
  }

  Future<void> _writeData(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  Map<String, dynamic> _seedData() {
    return {
      'users': [_defaultUser()],
      'sessions': <Map<String, dynamic>>[],
      'painAssessments': _defaultPainAssessments(),
      'techniqueSessions': <Map<String, dynamic>>[],
      'feedbacks': <Map<String, dynamic>>[],
      'techniques': _defaultTechniques(),
    };
  }

  Map<String, dynamic> _defaultUser() {
    final now = DateTime.now().toIso8601String();
    return {
      'id': 1,
      'fullName': 'Bernardo Oliveira Bencke',
      'age': 23,
      'sex': 'Masculino',
      'phoneNumber': '51 999947144',
      'email': 'bernardoobencke@gmail.com',
      'password': 'ber123',
      'comorbidities': [
        'Artrite',
        'Dor cronica',
        'Hipertensao arterial',
      ],
      'accessibility': {
        'fontScale': 1.0,
        'highContrast': false,
        'voiceReading': false,
      },
      'consentLgpd': true,
      'acceptedAt': now,
      'policyVersion': 'offline-seed',
    };
  }

  List<Map<String, dynamic>> _defaultTechniques() {
    return [
      {
        'id': 1,
        'name': 'Alongamento de Maos',
        'shortDescription': '5 min - Bom para rigidez matinal.',
        'warningText': 'Atencao: interrompa caso sinta dor intensa.',
        'steps': [
          {'order': 1, 'description': 'Sente-se confortavelmente.'},
          {'order': 2, 'description': 'Abra as maos lentamente.'},
          {'order': 3, 'description': 'Feche as maos formando um punho suave.'},
          {'order': 4, 'description': 'Repita o movimento 10 vezes.'},
          {'order': 5, 'description': 'Descanse ao final.'},
        ],
      },
      {
        'id': 2,
        'name': 'Respiracao Profunda',
        'shortDescription': '5 min - Reduz tensao e ansiedade.',
        'warningText': 'Dica: antes de dormir potencializa relaxamento.',
        'steps': [
          {'order': 1, 'description': 'Sente-se ou deite-se confortavelmente.'},
          {'order': 2, 'description': 'Coloque uma mao sobre o abdomen.'},
          {'order': 3, 'description': 'Inspire pelo nariz contando ate 4.'},
          {
            'order': 4,
            'description': 'Permita que o abdomen se eleve (nao o peito).'
          },
          {'order': 5, 'description': 'Expire pela boca contando ate 6.'},
          {'order': 6, 'description': 'Repita o processo 10 vezes.'},
        ],
      },
      {
        'id': 3,
        'name': 'Respiracao 4-7-8',
        'shortDescription': '3-5 min - Acalma e melhora o sono.',
        'warningText': 'Observacao: pode causar leve tontura no inicio.',
        'steps': [
          {'order': 1, 'description': 'Inspire pelo nariz contando ate 4.'},
          {'order': 2, 'description': 'Retenha o ar contando ate 7.'},
          {'order': 3, 'description': 'Expire pela boca contando ate 8.'},
          {'order': 4, 'description': 'Realize 4 ciclos completos.'},
        ],
      },
      {
        'id': 4,
        'name': 'Suspiro de Alivio',
        'shortDescription': '2 min - Libera tensao rapidamente.',
        'warningText': 'Use sempre que precisar desacelerar.',
        'steps': [
          {'order': 1, 'description': 'Inspire profundamente pelo nariz.'},
          {
            'order': 2,
            'description': 'Solte o ar pela boca emitindo um suspiro audivel.'
          },
          {'order': 3, 'description': 'Relaxe os ombros durante a expiracao.'},
          {'order': 4, 'description': 'Repita 5 vezes.'},
        ],
      },
      {
        'id': 5,
        'name': 'Relaxamento Muscular',
        'shortDescription': '10-15 min - Alivio de tensao e dor muscular.',
        'warningText': 'Atencao: nao force areas doloridas.',
        'steps': [
          {'order': 1, 'description': 'Deite-se confortavelmente.'},
          {
            'order': 2,
            'description': 'Inicie pelos pes: contraia por 5s e relaxe por 10s.'
          },
          {'order': 3, 'description': 'Repita nas panturrilhas.'},
          {'order': 4, 'description': 'Continue para as coxas.'},
          {'order': 5, 'description': 'Prossiga para o abdomen.'},
          {'order': 6, 'description': 'Repita em maos e bracos.'},
          {'order': 7, 'description': 'Continue pelos ombros.'},
          {'order': 8, 'description': 'Finalize com o rosto.'},
        ],
      },
      {
        'id': 6,
        'name': 'Toque Calmante',
        'shortDescription': '5 min - Conforto imediato na regiao dolorida.',
        'warningText': 'Imagine o calor promovendo alivio.',
        'steps': [
          {'order': 1, 'description': 'Esfregue as maos ate senti-las aquecidas.'},
          {'order': 2, 'description': 'Posicione as maos sobre a area dolorida.'},
          {'order': 3, 'description': 'Realize movimentos circulares leves.'},
          {
            'order': 4,
            'description': 'Respire profundamente enquanto aplica o toque.'
          },
          {'order': 5, 'description': 'Mantenha o foco na sensacao de alivio.'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _defaultPainAssessments() {
    final now = DateTime.now();
    final List<int> pains = [5, 5, 4, 4, 4, 3, 3, 3, 2, 2];
    final List<Map<String, dynamic>> items = [];
    for (var i = 0; i < pains.length; i++) {
      final day = now.subtract(Duration(days: pains.length - 1 - i));
      items.add({
        'id': i + 1,
        'userId': 1,
        'date': day.toIso8601String(),
        'usualPain': pains[i],
        'localizedPain': (pains[i].clamp(2, 5)) as int,
        'moodToday': 3,
        'sleepQuality': 3,
        'limitsPhysicalActivities': pains[i] >= 4,
        'painWorseWithMovement': pains[i] >= 3,
        'usesPainMedication': pains[i] >= 4,
        'usesNonDrugPainRelief': true,
        'notes': 'Registro offline auto-gerado',
      });
    }
    return items;
  }

  void _ensureSeeds(Map<String, dynamic> data) {
    data.putIfAbsent('users', () => [_defaultUser()]);
    data.putIfAbsent('sessions', () => <Map<String, dynamic>>[]);
    data.putIfAbsent('painAssessments', _defaultPainAssessments);
    data.putIfAbsent('techniqueSessions', () => <Map<String, dynamic>>[]);
    data.putIfAbsent('feedbacks', () => <Map<String, dynamic>>[]);
    data.putIfAbsent('techniques', _defaultTechniques);

    final users = (data['users'] as List).cast<Map<String, dynamic>>();
    final hasSeed =
        users.any((u) => u['email'] == 'bernardoobencke@gmail.com');
    if (!hasSeed) {
      users.add(_defaultUser());
    }
    data['users'] = users;
  }

  int _nextId(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return 1;
    final ids =
        list.map((e) => (e['id'] as int?) ?? 0).toList(growable: false);
    return ids.reduce(max) + 1;
  }

  int? _userIdFromToken(Map<String, dynamic> data, String token) {
    final sessions = (data['sessions'] as List).cast<Map<String, dynamic>>();
    final match =
        sessions.cast<Map<String, dynamic>>().where((s) => s['token'] == token);
    if (match.isNotEmpty) {
      return match.first['userId'] as int?;
    }

    if (token.startsWith('offline-')) {
      final parts = token.split('-');
      if (parts.length >= 3) {
        final parsed = int.tryParse(parts[1]);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  String _newTokenForUser(int userId) {
    return 'offline-$userId-${DateTime.now().millisecondsSinceEpoch}';
  }

  UserProfile _toUserProfile(Map<String, dynamic> user) {
    return UserProfile(
      id: user['id'] as int,
      fullName: user['fullName'] as String,
      age: user['age'] as int?,
      sex: user['sex'] as String?,
      phoneNumber: user['phoneNumber'] as String?,
      email: user['email'] as String,
      comorbidities: (user['comorbidities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      accessibility: user['accessibility'] != null
          ? AccessibilityPreference.fromJson(
              (user['accessibility'] as Map).cast<String, dynamic>(),
            )
          : null,
      consent: ConsentLgpd(
        accepted: (user['consentLgpd'] ?? false) as bool,
        acceptedAt: user['acceptedAt'] != null
            ? DateTime.tryParse(user['acceptedAt'] as String)
            : null,
        policyVersion: user['policyVersion'] as String?,
      ),
    );
  }

  Future<AuthResponse> loginOffline(String email, String password) async {
    final data = await _readData();
    final users = (data['users'] as List).cast<Map<String, dynamic>>();
    final user = users.firstWhere(
      (u) =>
          (u['email'] as String).toLowerCase() == email.toLowerCase() &&
          (u['password'] as String) == password,
      orElse: () => {},
    );

    if (user.isEmpty) {
      throw Exception('Credenciais invalidas (modo offline)');
    }

    final token = _newTokenForUser(user['id'] as int);
    final sessions = (data['sessions'] as List).cast<Map<String, dynamic>>();
    sessions.add({
      'token': token,
      'userId': user['id'],
      'createdAt': DateTime.now().toIso8601String(),
    });
    data['sessions'] = sessions;
    await _writeData(data);

    return AuthResponse(
      token: token,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  Future<AuthResponse> registerOffline(RegisterRequest request) async {
    final data = await _readData();
    final users = (data['users'] as List).cast<Map<String, dynamic>>();

    final exists = users.any(
      (u) =>
          (u['email'] as String).toLowerCase() ==
          request.email.toLowerCase(),
    );
    if (exists) {
      return loginOffline(request.email, request.password);
    }

    final newUser = {
      'id': _nextId(users),
      'fullName': request.fullName,
      'age': request.age,
      'sex': request.sex,
      'phoneNumber': request.phoneNumber,
      'email': request.email,
      'password': request.password,
      'comorbidities': request.comorbidities,
      'accessibility': {
        'fontScale': request.fontScale,
        'highContrast': request.highContrast,
        'voiceReading': request.voiceReading,
      },
      'consentLgpd': request.consentLgpd,
      'acceptedAt': DateTime.now().toIso8601String(),
      'policyVersion': 'offline-consent',
    };

    users.add(newUser);
    data['users'] = users;

    final token = _newTokenForUser(newUser['id'] as int);
    final sessions = (data['sessions'] as List).cast<Map<String, dynamic>>();
    sessions.add({
      'token': token,
      'userId': newUser['id'],
      'createdAt': DateTime.now().toIso8601String(),
    });
    data['sessions'] = sessions;

    await _writeData(data);

    return AuthResponse(
      token: token,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  Future<UserProfile> getProfile(String token) async {
    final data = await _readData();
    final userId = _userIdFromToken(data, token);
    if (userId == null) {
      throw Exception('Token offline invalido');
    }

    final users = (data['users'] as List).cast<Map<String, dynamic>>();
    final user = users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => {},
    );
    if (user.isEmpty) {
      throw Exception('Usuario nao encontrado no cache.');
    }

    return _toUserProfile(user);
  }

  Future<UserProfile> updateProfile(
    String token,
    UpdateUserProfileRequest request,
  ) async {
    final data = await _readData();
    final userId = _userIdFromToken(data, token);
    if (userId == null) {
      throw Exception('Token offline invalido');
    }

    final users = (data['users'] as List).cast<Map<String, dynamic>>();
    final index = users.indexWhere((u) => u['id'] == userId);
    if (index == -1) {
      throw Exception('Usuario nao encontrado no cache.');
    }

    final updated = {...users[index]};
    updated['fullName'] = request.fullName;
    updated['age'] = request.age;
    updated['sex'] = request.sex;
    updated['phoneNumber'] = request.phoneNumber;
    updated['comorbidities'] = request.comorbidities;
    updated['accessibility'] = {
      'fontScale': request.fontScale,
      'highContrast': request.highContrast,
      'voiceReading': request.voiceReading,
    };
    updated['consentLgpd'] = request.acceptLgpd;
    updated['acceptedAt'] = DateTime.now().toIso8601String();

    users[index] = updated;
    data['users'] = users;
    await _writeData(data);

    return _toUserProfile(updated);
  }

  Future<void> addPainAssessment(
    String token,
    PainAssessmentRequest request,
  ) async {
    final data = await _readData();
    final userId = _userIdFromToken(data, token);
    if (userId == null) return;

    final assessments =
        (data['painAssessments'] as List).cast<Map<String, dynamic>>();
    assessments.add({
      'id': _nextId(assessments),
      'userId': userId,
      'date': DateTime.now().toIso8601String(),
      'usualPain': request.usualPain,
      'localizedPain': request.localizedPain,
      'moodToday': request.moodToday,
      'sleepQuality': request.sleepQuality,
      'limitsPhysicalActivities': request.limitsPhysicalActivities,
      'painWorseWithMovement': request.painWorseWithMovement,
      'usesPainMedication': request.usesPainMedication,
      'usesNonDrugPainRelief': request.usesNonDrugPainRelief,
      'notes': request.notes,
    });
    data['painAssessments'] = assessments;
    await _writeData(data);
  }

  Future<PainReport> getPainReport(String token, {int days = 7}) async {
    final data = await _readData();
    final userId = _userIdFromToken(data, token);
    if (userId == null) {
      throw Exception('Token offline invalido');
    }

    final assessments =
        (data['painAssessments'] as List).cast<Map<String, dynamic>>();
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));

    final perDay = <DateTime, List<int>>{};
    for (final item in assessments.where((a) => a['userId'] == userId)) {
      final date = DateTime.tryParse(item['date'] as String? ?? '');
      if (date == null || date.isBefore(cutoff)) continue;
      final key = DateTime(date.year, date.month, date.day);
      perDay.putIfAbsent(key, () => []);
      perDay[key]!.add(item['usualPain'] as int? ?? 0);
    }

    final evolution = perDay.entries.map((entry) {
      final avg = entry.value.isEmpty
          ? 0
          : entry.value.reduce((a, b) => a + b) / entry.value.length;
      return PainEvolutionPoint(
        date: entry.key,
        averagePain: avg.toDouble(),
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double? reduction;
    if (evolution.length >= 2) {
      final first = evolution.first.averagePain;
      final last = evolution.last.averagePain;
      if (first != 0) {
        reduction = ((first - last) / first) * 100;
      }
    }

    return PainReport(
      evolution: evolution,
      percentageReduction: reduction,
    );
  }

  Future<List<ReliefTechniqueListItem>> getTechniques() async {
    final data = await _readData();
    final list = (data['techniques'] as List).cast<Map<String, dynamic>>();
    return list
        .map((t) => ReliefTechniqueListItem(
              id: t['id'] as int,
              name: t['name'] as String,
              shortDescription: t['shortDescription'] as String,
              warningText: t['warningText'] as String?,
            ))
        .toList();
  }

  Future<ReliefTechniqueDetail> getTechniqueDetail(int id) async {
    final data = await _readData();
    final list = (data['techniques'] as List).cast<Map<String, dynamic>>();
    final found = list.firstWhere(
      (t) => t['id'] == id,
      orElse: () => {},
    );
    if (found.isEmpty) {
      throw Exception('Tecnica nao encontrada no cache.');
    }
    final steps = (found['steps'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(
          (s) => TechniqueStep(
            order: s['order'] as int,
            description: s['description'] as String,
          ),
        )
        .toList();

    return ReliefTechniqueDetail(
      id: found['id'] as int,
      name: found['name'] as String,
      shortDescription: found['shortDescription'] as String,
      warningText: found['warningText'] as String?,
      steps: steps,
    );
  }

  Future<void> registerTechniqueSession(
    String token,
    TechniqueSessionRequest request,
  ) async {
    final data = await _readData();
    final userId = _userIdFromToken(data, token);
    if (userId == null) return;

    final sessions =
        (data['techniqueSessions'] as List).cast<Map<String, dynamic>>();
    sessions.add({
      'id': _nextId(sessions),
      'userId': userId,
      'reliefTechniqueId': request.reliefTechniqueId,
      'startedAt': request.startedAt.toIso8601String(),
      'finishedAt': request.finishedAt.toIso8601String(),
      'resultFeeling': request.resultFeeling,
      'notes': request.notes,
    });
    data['techniqueSessions'] = sessions;
    await _writeData(data);
  }

  Future<void> sendGeneralFeedback(
    String token,
    GeneralFeedbackRequest request,
  ) async {
    final data = await _readData();
    final userId = _userIdFromToken(data, token);
    if (userId == null) return;

    final feedbacks =
        (data['feedbacks'] as List).cast<Map<String, dynamic>>();
    feedbacks.add({
      'id': _nextId(feedbacks),
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
      'generalFeeling': request.generalFeeling,
      'text': request.text,
    });
    data['feedbacks'] = feedbacks;
    await _writeData(data);
  }

  Future<UserDataExport> getUserDataExport(String token) async {
    final data = await _readData();
    final userId = _userIdFromToken(data, token);
    if (userId == null) {
      throw Exception('Token offline invalido');
    }
    return _buildUserDataExport(data, userId);
  }

  Future<List<UserDataExport>> getAllUsersDataExport() async {
    final data = await _readData();
    final users = (data['users'] as List).cast<Map<String, dynamic>>();
    return users
        .map((u) => _buildUserDataExport(data, u['id'] as int))
        .toList();
  }

  UserDataExport _buildUserDataExport(
    Map<String, dynamic> data,
    int userId,
  ) {
    final users = (data['users'] as List).cast<Map<String, dynamic>>();
    final user = users.firstWhere((u) => u['id'] == userId);
    final comorbidities = (user['comorbidities'] as List<dynamic>? ?? [])
        .asMap()
        .entries
        .map(
          (e) => UserComorbidityExport(
            id: e.key + 1,
            userId: userId,
            name: e.value.toString(),
          ),
        )
        .toList();

    final painAssessments =
        (data['painAssessments'] as List).cast<Map<String, dynamic>>();
    final techniqueSessions =
        (data['techniqueSessions'] as List).cast<Map<String, dynamic>>();
    final feedbacks =
        (data['feedbacks'] as List).cast<Map<String, dynamic>>();
    final techniques =
        (data['techniques'] as List).cast<Map<String, dynamic>>();

    final painAssessmentExports = painAssessments
        .where((p) => p['userId'] == userId)
        .map(
          (p) => PainAssessmentExport(
            id: p['id'] as int,
            userId: userId,
            date: DateTime.parse(p['date'] as String),
            usualPain: p['usualPain'] as int,
            localizedPain: p['localizedPain'] as int,
            moodToday: p['moodToday'] as int,
            sleepQuality: p['sleepQuality'] as int,
            limitsPhysicalActivities:
                p['limitsPhysicalActivities'] as bool? ?? false,
            painWorseWithMovement:
                p['painWorseWithMovement'] as bool? ?? false,
            usesPainMedication: p['usesPainMedication'] as bool? ?? false,
            usesNonDrugPainRelief:
                p['usesNonDrugPainRelief'] as bool? ?? false,
            notes: p['notes'] as String?,
          ),
        )
        .toList();

    final sessionExports = techniqueSessions
        .where((s) => s['userId'] == userId)
        .map(
          (s) => TechniqueSessionExport(
            id: s['id'] as int,
            userId: userId,
            reliefTechniqueId: s['reliefTechniqueId'] as int,
            startedAt: DateTime.parse(s['startedAt'] as String),
            finishedAt: DateTime.parse(s['finishedAt'] as String),
            resultFeeling: s['resultFeeling'] as int,
            notes: s['notes'] as String?,
          ),
        )
        .toList();

    final feedbackExports = feedbacks
        .where((f) => f['userId'] == userId)
        .map(
          (f) => GeneralFeedbackExport(
            id: f['id'] as int,
            userId: userId,
            createdAt: DateTime.parse(f['createdAt'] as String),
            generalFeeling: f['generalFeeling'] as int?,
            text: f['text'] as String?,
          ),
        )
        .toList();

    final reliefTechniqueExports = techniques
        .map(
          (t) => ReliefTechniqueExport(
            id: t['id'] as int,
            name: t['name'] as String,
            shortDescription: t['shortDescription'] as String?,
            warningText: t['warningText'] as String?,
          ),
        )
        .toList();

    final techniqueStepExports = techniques
        .expand(
          (t) => (t['steps'] as List<dynamic>? ?? []).map(
            (s) => TechniqueStepExport(
              id: ((s as Map<String, dynamic>)['order'] as int?) ?? 0,
              reliefTechniqueId: t['id'] as int,
              order: s['order'] as int? ?? 0,
              description: s['description'] as String? ?? '',
            ),
          ),
        )
        .toList();

    return UserDataExport(
      user: _toUserProfile(user),
      comorbidities: comorbidities,
      painAssessments: painAssessmentExports,
      techniqueSessions: sessionExports,
      generalFeedbacks: feedbackExports,
      reliefTechniques: reliefTechniqueExports,
      techniqueSteps: techniqueStepExports,
    );
  }
}
