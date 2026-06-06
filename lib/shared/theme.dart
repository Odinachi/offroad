import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JemenaiTheme {
  // Gradients
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

  // Status Bar / Phone Frame details
  static const Color hardwareButtonDark = Color(0xFF2A2A3A);
  static const Color hardwareButtonLight = Color(0xFFC5C5D0);

  // Shadows
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

  // Get colors matching CSS variables
  static Color background(bool isDark) =>
      isDark ? const Color(0xFF09090B) : const Color(0xFFFAFAFA);
  static Color foreground(bool isDark) =>
      isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B);
  static Color card(bool isDark) =>
      isDark ? const Color(0xFF111113) : const Color(0xFFFFFFFF);
  static Color border(bool isDark) =>
      isDark
          ? Colors.white.withOpacity(0.07)
          : const Color(0xFF09090B).withOpacity(0.08);
  static Color primary(bool isDark) =>
      isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
  static Color secondary(bool isDark) =>
      isDark ? const Color(0xFF1C1C25) : const Color(0xFFF4F4F5);
  static Color muted(bool isDark) =>
      isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);
  static Color mutedForeground(bool isDark) => const Color(0xFF71717A);
  static Color accent(bool isDark) =>
      isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEDE9FE);
  static Color accentForeground(bool isDark) =>
      isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5);
  static Color destructive(bool isDark) =>
      isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
  static Color switchBackground(bool isDark) =>
      isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8);
  static Color navBackground(bool isDark) =>
      isDark
          ? const Color(0xFF09090B).withOpacity(0.88)
          : const Color(0xFFFAFAFA).withOpacity(0.88);

  static Color jmIndigo(bool isDark) =>
      isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
  static Color jmViolet(bool isDark) =>
      isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);

  // Text themes
  static TextStyle fontDisplay({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? lineHeight,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: lineHeight,
    );
  }

  static TextStyle fontBody({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? lineHeight,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: lineHeight,
    );
  }
}
