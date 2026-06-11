import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jemenai/features/dashboard/view_models/app_cubit.dart';
import '../../../shared/theme.dart';
import 'huggingface_token_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifs = true;
  bool _analytics = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;

    final isDark = theme.brightness == Brightness.dark;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: JemenaiTheme.gradBrand,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: JemenaiTheme.glowSm(isDark),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'AW',
                      style: JemenaiTheme.fontDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex Wilson',
                          style: JemenaiTheme.fontDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: foreColor,
                          ),
                        ),
                        Text(
                          'alex@example.com',
                          style: JemenaiTheme.fontBody(
                            fontSize: 12,
                            color: mutedFore,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Pro Plan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4ADE80),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Appearance Section
            _buildSection(
              label: 'Appearance',
              children: [
                _buildToggleRow(
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  iBg:
                      isDark
                          ? const Color(0xFF1E1B4B)
                          : const Color(0xFFFEF3C7),
                  iColor:
                      isDark
                          ? const Color(0xFF818CF8)
                          : const Color(0xFFD97706),
                  title: 'Dark Mode',
                  sub: isDark ? 'Dark theme active' : 'Light theme active',
                  value: context.watch<AppCubit>().isDarkTheme,
                  onChanged: (val) {
                    context.read<AppCubit>().toggleTheme();
                  },
                ),
              ],
            ),

            // Hardware & Performance Section
            _buildSection(
              label: 'Hardware & Performance',
              children: [
                _buildChipSelectorRow(
                  icon: Icons.memory,
                  iBg: const Color(0xFF1E1B4B),
                  iColor: const Color(0xFF818CF8),
                  title: 'Inference Engine',
                  sub: 'Choose processing hardware for local models',
                  value: context.watch<AppCubit>().inferenceEngine,
                  options: const ['gpu', 'cpu'],
                  optionLabels: const {
                    'gpu': 'GPU (Accelerated)',
                    'cpu': 'CPU (Standard)',
                  },
                  onChanged: (val) {
                    context.read<AppCubit>().saveInferenceEngine(val);
                  },
                ),
                _buildNavRow(
                  icon: Icons.vpn_key,
                  iBg: const Color(0xFF1E1B4B),
                  iColor: const Color(0xFF818CF8),
                  title: 'Hugging Face Token',
                  sub: 'Set up credentials to access models',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HuggingFaceTokenScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Privacy & Security Section
            _buildSection(
              label: 'Privacy & Security',
              children: [
                _buildNavRow(
                  icon: Icons.shield,
                  iBg: const Color(0xFF022016),
                  iColor: const Color(0xFF4ADE80),
                  title: 'Privacy Controls',
                  sub: 'All data stays on-device',
                  showChevron: false,
                ),
              ],
            ),

            // About Section
            _buildSection(
              label: 'About',
              children: [
                _buildNavRow(
                  icon: Icons.auto_awesome,
                  iBg: const Color(0xFF1E1B4B),
                  iColor: const Color(0xFF818CF8),
                  title: 'OffRoad',
                  sub: 'Version 2.0.0 · June 2026',
                  rightWidget: Text(
                    'Latest',
                    style: JemenaiTheme.fontBody(
                      fontSize: 11,
                      color: mutedFore,
                    ),
                  ),
                  showChevron: false,
                ),
                _buildNavRow(
                  icon: Icons.smartphone,
                  iBg: const Color(0xFF1A1A2E),
                  iColor: const Color(0xFF6366F1),
                  title: 'Device',
                  sub: 'iPhone 15 Pro · 128 GB',
                  showChevron: false,
                ),
                _buildNavRow(
                  icon: Icons.info_outline,
                  iBg: const Color(0xFF1A1A2E),
                  iColor: const Color(0xFF6366F1),
                  title: 'Terms & Privacy Policy',
                  onTap: () {},
                ),
              ],
            ),

            // Sign Out
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.logout,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'Sign Out',
                  style: JemenaiTheme.fontBody(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: theme.colorScheme.error.withOpacity(0.25),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final border = jc.border;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6.0, bottom: 8.0),
            child: Text(
              label.toUpperCase(),
              style: JemenaiTheme.fontBody(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: jc.mutedForeground,
                lineHeight: 1.0,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: jc.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
              boxShadow: JemenaiTheme.shadowCard(isDark),
            ),
            child: Column(
              children: List.generate(children.length, (index) {
                final isLast = index == children.length - 1;
                return Column(
                  children: [
                    children[index],
                    if (!isLast)
                      Divider(height: 1, thickness: 1, color: border),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iBg,
    required Color iColor,
    required String title,
    required String sub,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    final jc = theme.jColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: JemenaiTheme.fontBody(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: JemenaiTheme.fontBody(
                    fontSize: 11,
                    color: jc.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required Color iBg,
    required Color iColor,
    required String title,
    String? sub,
    VoidCallback? onTap,
    Widget? rightWidget,
    bool showChevron = true,
  }) {
    final theme = Theme.of(context);
    final jc = theme.jColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: JemenaiTheme.fontBody(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: JemenaiTheme.fontBody(
                        fontSize: 11,
                        color: jc.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (rightWidget != null) rightWidget,
            if (showChevron && onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: jc.mutedForeground,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChipSelectorRow({
    required IconData icon,
    required Color iBg,
    required Color iColor,
    required String title,
    required String sub,
    required String value,
    required List<String> options,
    Map<String, String>? optionLabels,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: JemenaiTheme.fontBody(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: JemenaiTheme.fontBody(
                        fontSize: 11,
                        color: jc.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chips Selection Row
          Row(
            children:
                options.map((opt) {
                  final isSel = value == opt;
                  final label = optionLabels != null ? optionLabels[opt]! : opt;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: InkWell(
                        onTap: () => onChanged(opt),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: isSel ? JemenaiTheme.gradBrand : null,
                            color: isSel ? null : jc.secondaryFill,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSel ? JemenaiTheme.glowSm(isDark) : [],
                          ),
                          child: Text(
                            label,
                            style: JemenaiTheme.fontBody(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : jc.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
