import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/user_service.dart';

/// Controla preferências de acessibilidade (contraste e tamanho da fonte) e
/// notifica widgets inscritos para que se redesenhem.
class AccessibilityController extends ChangeNotifier {
  AccessibilityController._internal();

  static final AccessibilityController instance =
      AccessibilityController._internal();

  final _userService = UserService();

  double _fontScale = 1.0;
  bool _highContrast = false;
  String? _loadedToken;

  double get fontScale => _fontScale;
  bool get highContrast => _highContrast;

  AccessibilityPalette get palette => _highContrast
      ? const AccessibilityPalette(
          backgroundColor: Colors.black,
          primaryColor: Color(0xFFFFD54F),
          cardColor: Color(0xFF121212),
          textColor: Colors.white,
          mutedTextColor: Colors.white70,
          buttonForegroundColor: Colors.black,
        )
      : const AccessibilityPalette(
          backgroundColor: Color(0xFFE0E0E0),
          primaryColor: Color(0xFF2E7C8A),
          cardColor: Colors.white,
          textColor: Colors.black87,
          mutedTextColor: Colors.black54,
          buttonForegroundColor: Colors.white,
        );

  /// Carrega preferências do backend e aplica ao controlador.
  Future<void> loadFromToken(String? token) async {
    if (token == null || token.isEmpty) return;
    if (_loadedToken == token) return;

    try {
      final profile = await _userService.getProfile(token);
      _applyFromProfile(profile.accessibility);
      _loadedToken = token;
    } catch (_) {
      // Silencia erros para não bloquear a renderização da tela;
      // caso falhe, fica com valores padrão.
    }
  }

  /// Aplica preferências já conhecidas (por exemplo, após salvar o perfil).
  void updatePreferences({
    required double fontScale,
    required bool highContrast,
  }) {
    _fontScale = fontScale;
    _highContrast = highContrast;
    notifyListeners();
  }

  void _applyFromProfile(AccessibilityPreference? pref) {
    if (pref == null) return;
    _fontScale = pref.fontScale;
    _highContrast = pref.highContrast;
    notifyListeners();
  }
}

class AccessibilityPalette {
  final Color backgroundColor;
  final Color primaryColor;
  final Color cardColor;
  final Color textColor;
  final Color mutedTextColor;
  final Color buttonForegroundColor;

  const AccessibilityPalette({
    required this.backgroundColor,
    required this.primaryColor,
    required this.cardColor,
    required this.textColor,
    required this.mutedTextColor,
    required this.buttonForegroundColor,
  });
}

class AccessibilityScope extends InheritedWidget {
  final AccessibilityController controller;
  final AccessibilityPalette palette;

  const AccessibilityScope({
    super.key,
    required this.controller,
    required this.palette,
    required super.child,
  });

  static AccessibilityScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AccessibilityScope>();
    assert(scope != null, 'AccessibilityScope não encontrado no contexto.');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AccessibilityScope oldWidget) {
    return controller != oldWidget.controller ||
        palette != oldWidget.palette ||
        controller.fontScale != oldWidget.controller.fontScale ||
        controller.highContrast != oldWidget.controller.highContrast;
  }
}

/// Envolve qualquer tela aplicando contraste/escala de fonte conforme o perfil.
class AccessibilityWrapper extends StatefulWidget {
  final String? token;
  final Widget child;

  const AccessibilityWrapper({
    super.key,
    this.token,
    required this.child,
  });

  @override
  State<AccessibilityWrapper> createState() => _AccessibilityWrapperState();
}

class _AccessibilityWrapperState extends State<AccessibilityWrapper> {
  final AccessibilityController _controller = AccessibilityController.instance;

  @override
  void initState() {
    super.initState();
    _controller.loadFromToken(widget.token);
  }

  @override
  void didUpdateWidget(covariant AccessibilityWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _controller.loadFromToken(widget.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final palette = _controller.palette;
        final baseTheme = Theme.of(context);
        final themed = baseTheme.copyWith(
          scaffoldBackgroundColor: palette.backgroundColor,
          appBarTheme: baseTheme.appBarTheme.copyWith(
            backgroundColor: palette.backgroundColor,
            foregroundColor: palette.textColor,
            iconTheme: IconThemeData(color: palette.textColor),
          ),
          cardColor: palette.cardColor,
          textTheme: baseTheme.textTheme.apply(
            bodyColor: palette.textColor,
            displayColor: palette.textColor,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.primaryColor,
              foregroundColor: palette.buttonForegroundColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );

        return AccessibilityScope(
          controller: _controller,
          palette: palette,
          child: Theme(
            data: themed,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(_controller.fontScale),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
