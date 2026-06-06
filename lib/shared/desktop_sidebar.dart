import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'theme.dart';

class DesktopSidebar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleDark;

  const DesktopSidebar({
    super.key,
    required this.isDark,
    required this.onToggleDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      width: 260,
      padding: const EdgeInsets.only(left: 56), // Margin from mockup frame
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Branding Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: JemenaiTheme.gradBrand,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.4),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jemenai AI',
                      style: JemenaiTheme.fontDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        lineHeight: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Private AI. Anywhere.',
                      style: JemenaiTheme.fontBody(
                        fontSize: 13,
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Features List
          Column(
            children: [
              _buildFeatureRow('🔒', '100% on-device processing', subColor),
              _buildFeatureRow('📵', 'Works completely offline', subColor),
              _buildFeatureRow('⚡', 'Sub-second AI responses', subColor),
              _buildFeatureRow('🎙', 'Natural voice conversations', subColor),
              _buildFeatureRow('🛡', 'AES-256 local encryption', subColor),
              _buildFeatureRow('🎯', '16 specialized AI tools', subColor),
              _buildFeatureRow('📦', 'GGUF · ONNX · MLX models', subColor),
            ],
          ),
          const SizedBox(height: 32),

          // Theme Toggle Button
          InkWell(
            onTap: onToggleDark,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                ),
                color:
                    isDark
                        ? const Color(0xFF1E293B).withOpacity(0.2)
                        : Colors.white.withOpacity(0.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDark ? LucideIcons.sun : LucideIcons.moon,
                    size: 16,
                    color:
                        isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDark ? 'Light Mode' : 'Dark Mode',
                    style: JemenaiTheme.fontBody(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: JemenaiTheme.fontBody(fontSize: 13, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
