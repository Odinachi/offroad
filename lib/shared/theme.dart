import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────
// ThemeExtension — custom semantic tokens that have
// no direct ColorScheme equivalent.
// ──────────────────────────────────────────────────

class JemenaiColors extends ThemeExtension<JemenaiColors> {
  final Color card;
  final Color border;
  final Color muted;
  final Color mutedForeground;
  final Color secondaryFill;
  final Color accent;
  final Color accentForeground;
  final Color navBackground;
  final Color switchBackground;
  final Color jmIndigo;
  final Color jmViolet;

  const JemenaiColors({
    required this.card,
    required this.border,
    required this.muted,
    required this.mutedForeground,
    required this.secondaryFill,
    required this.accent,
    required this.accentForeground,
    required this.navBackground,
    required this.switchBackground,
    required this.jmIndigo,
    required this.jmViolet,
  });

  @override
  JemenaiColors copyWith({
    Color? card,
    Color? border,
    Color? muted,
    Color? mutedForeground,
    Color? secondaryFill,
    Color? accent,
    Color? accentForeground,
    Color? navBackground,
    Color? switchBackground,
    Color? jmIndigo,
    Color? jmViolet,
  }) {
    return JemenaiColors(
      card: card ?? this.card,
      border: border ?? this.border,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      secondaryFill: secondaryFill ?? this.secondaryFill,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      navBackground: navBackground ?? this.navBackground,
      switchBackground: switchBackground ?? this.switchBackground,
      jmIndigo: jmIndigo ?? this.jmIndigo,
      jmViolet: jmViolet ?? this.jmViolet,
    );
  }

  @override
  JemenaiColors lerp(covariant ThemeExtension<JemenaiColors>? other, double t) {
    if (other is! JemenaiColors) return this;
    return JemenaiColors(
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      secondaryFill: Color.lerp(secondaryFill, other.secondaryFill, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground: Color.lerp(accentForeground, other.accentForeground, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      switchBackground: Color.lerp(switchBackground, other.switchBackground, t)!,
      jmIndigo: Color.lerp(jmIndigo, other.jmIndigo, t)!,
      jmViolet: Color.lerp(jmViolet, other.jmViolet, t)!,
    );
  }

  // ── Light palette ──
  static const light = JemenaiColors(
    card: Color(0xFFFFFFFF),
    border: Color(0x1409090B), // ~8% black
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    secondaryFill: Color(0xFFF4F4F5),
    accent: Color(0xFFEDE9FE),
    accentForeground: Color(0xFF4F46E5),
    navBackground: Color(0xE0FAFAFA), // ~88% opacity
    switchBackground: Color(0xFFD4D4D8),
    jmIndigo: Color(0xFF4F46E5),
    jmViolet: Color(0xFF7C3AED),
  );

  // ── Dark palette ──
  static const dark = JemenaiColors(
    card: Color(0xFF111113),
    border: Color(0x12FFFFFF), // ~7% white
    muted: Color(0xFF18181B),
    mutedForeground: Color(0xFF71717A),
    secondaryFill: Color(0xFF1C1C25),
    accent: Color(0xFF1E1B4B),
    accentForeground: Color(0xFFA5B4FC),
    navBackground: Color(0xE009090B), // ~88% opacity
    switchBackground: Color(0xFF3F3F46),
    jmIndigo: Color(0xFF818CF8),
    jmViolet: Color(0xFFA78BFA),
  );
}

// ──────────────────────────────────────────────────
// Convenience extension on ThemeData
// ──────────────────────────────────────────────────

extension JemenaiThemeX on ThemeData {
  JemenaiColors get jColors => extension<JemenaiColors>()!;
}

// ──────────────────────────────────────────────────
// Theme Factory + Static Utilities
// ──────────────────────────────────────────────────

class JemenaiTheme {
  JemenaiTheme._(); // non-instantiable

  // ── ThemeData Factories ──

  static ThemeData lightTheme() {
    final textTheme = _buildTextTheme(Brightness.light);
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4F46E5),
        onPrimary: Colors.white,
        secondary: Color(0xFFF4F4F5),
        onSecondary: Color(0xFF09090B),
        surface: Color(0xFFFAFAFA),
        onSurface: Color(0xFF09090B),
        error: Color(0xFFEF4444),
        onError: Colors.white,
        tertiary: Color(0xFF7C3AED),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF09090B),
        elevation: 0,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF09090B),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4F4F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x404F46E5), width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const Color(0xFF4F46E5)
              : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const Color(0xFF4F46E5).withOpacity(0.5)
              : const Color(0xFFD4D4D8);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: const [JemenaiColors.light],
    );
  }

  static ThemeData darkTheme() {
    final textTheme = _buildTextTheme(Brightness.dark);
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF09090B),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF818CF8),
        onPrimary: Colors.white,
        secondary: Color(0xFF1C1C25),
        onSecondary: Color(0xFFFAFAFA),
        surface: Color(0xFF09090B),
        onSurface: Color(0xFFFAFAFA),
        error: Color(0xFFF87171),
        onError: Colors.white,
        tertiary: Color(0xFFA78BFA),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF111113),
        foregroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFAFAFA),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF111113),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF18181B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF818CF8).withOpacity(0.25),
            width: 2,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const Color(0xFF818CF8)
              : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const Color(0xFF818CF8).withOpacity(0.5)
              : const Color(0xFF3F3F46);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: const [JemenaiColors.dark],
    );
  }

  // ── TextTheme builder ──

  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? const Color(0xFFFAFAFA)
        : const Color(0xFF09090B);

    return TextTheme(
      displayLarge: TextStyle(color: color, fontFamily: 'PlusJakartaSans'),
      displayMedium: TextStyle(color: color, fontFamily: 'PlusJakartaSans'),
      displaySmall: TextStyle(color: color, fontFamily: 'PlusJakartaSans'),
      headlineLarge: TextStyle(color: color, fontFamily: 'PlusJakartaSans'),
      headlineMedium: TextStyle(color: color, fontFamily: 'PlusJakartaSans'),
      headlineSmall: TextStyle(color: color, fontFamily: 'PlusJakartaSans'),
      titleLarge: TextStyle(color: color, fontFamily: 'PlusJakartaSans'),
      titleMedium: TextStyle(color: color, fontFamily: 'PlusJakartaSans'),
      titleSmall: TextStyle(color: color, fontFamily: 'PlusJakartaSans'),
      bodyLarge: TextStyle(color: color, fontFamily: 'Inter'),
      bodyMedium: TextStyle(color: color, fontFamily: 'Inter'),
      bodySmall: TextStyle(color: color, fontFamily: 'Inter'),
      labelLarge: TextStyle(color: color, fontFamily: 'Inter'),
      labelMedium: TextStyle(color: color, fontFamily: 'Inter'),
      labelSmall: TextStyle(color: color, fontFamily: 'Inter'),
    );
  }

  // ──────────────────────────────────────────────────
  // Static Gradients
  // ──────────────────────────────────────────────────

  static const Gradient gradBrand = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient gradSubtleLight = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient gradSubtleDark = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF2E1065)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ──────────────────────────────────────────────────
  // Static Shadows & Glows (need explicit isDark flag)
  // ──────────────────────────────────────────────────

  static List<BoxShadow> shadowCard(bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 16,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          offset: const Offset(0, 4),
          blurRadius: 16,
        ),
      ];
    }
  }

  static List<BoxShadow> shadowFloat(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.5 : 0.12),
        offset: const Offset(0, 8),
        blurRadius: 32,
      ),
    ];
  }

  static List<BoxShadow> shadowDeep(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.6 : 0.18),
        offset: const Offset(0, 24),
        blurRadius: 64,
      ),
    ];
  }

  static List<BoxShadow> glowSm(bool isDark) {
    return [
      BoxShadow(
        color: const Color(0xFF6366F1).withOpacity(isDark ? 0.20 : 0.18),
        offset: Offset.zero,
        blurRadius: 20,
      ),
    ];
  }

  static List<BoxShadow> glowMd(bool isDark) {
    return [
      BoxShadow(
        color: const Color(0xFF6366F1).withOpacity(isDark ? 0.25 : 0.22),
        offset: Offset.zero,
        blurRadius: 40,
      ),
    ];
  }

  // ──────────────────────────────────────────────────
  // Convenience text style builders (kept for gradual migration)
  // ──────────────────────────────────────────────────

  static TextStyle fontDisplay({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? lineHeight,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: lineHeight,
      fontFamily: 'PlusJakartaSans',
    );
  }

  static TextStyle fontBody({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? lineHeight,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: lineHeight,
      fontFamily: 'Inter',
    );
  }
}

class AppColors {
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color jmIndigo = Color(0xFF4F46E5);
  static const Color jmViolet = Color(0xFF7C3AED);
  static const Color jmPurple = Color(0xFF8B5CF6);
  static const Color jmPink = Color(0xFFFF006E);
  static const Color jmTeal = Color(0xFF14B8A6);
  static const Color jmGreen = Color(0xFF22C55E);
  static const Color jmYellow = Color(0xFFFFC107);
  static const Color jmOrange = Color(0xFFFF9800);
  static const Color jmRed = Color(0xFFFF5252);
}
