import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jemenai/features/dashboard/view_models/app_cubit.dart';
import 'package:jemenai/services/db_service.dart';
import 'package:jemenai/services/storage_service.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:jemenai/shared/ui_helpers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../shared/theme.dart';
import 'huggingface_token_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _version;
  String? _device;

  @override
  void initState() {
    super.initState();
    _loadAbout();
  }

  Future<void> _loadAbout() async {
    String? version;
    try {
      final info = await PackageInfo.fromPlatform();
      version = 'Version ${info.version} (${info.buildNumber})';
    } catch (_) {}

    final platform =
        kIsWeb
            ? 'Web'
            : switch (defaultTargetPlatform) {
              TargetPlatform.iOS => 'iOS ${_osVersion()}',
              TargetPlatform.android => 'Android ${_osVersion()}',
              TargetPlatform.macOS => 'macOS',
              _ => defaultTargetPlatform.name,
            };
    final total = await StorageService.getTotalDiskSpaceGB();
    final free = await StorageService.getFreeDiskSpaceGB();
    final storage =
        total == null
            ? null
            : free == null
            ? '${total.round()} GB'
            : '${free.toStringAsFixed(0)} of ${total.round()} GB free';

    if (!mounted) return;
    setState(() {
      _version = version;
      _device = [platform, if (storage != null) storage].join(' · ');
    });
  }

  static String _osVersion() {
    // e.g. "Version 18.5 (Build 22F76)" → "18.5"
    final match = RegExp(
      r'(\d+(\.\d+)*)',
    ).firstMatch(Platform.operatingSystemVersion);
    return match?.group(1) ?? '';
  }

  Future<void> _deleteAllChats() async {
    final count = await DatabaseService().countSessions();
    if (!mounted) return;
    if (count == 0) {
      AppRouter.showMessage('There are no conversations to delete.');
      return;
    }
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete all conversations?',
      message:
          'This permanently removes $count conversation${count == 1 ? '' : 's'} '
          'from this device. Downloaded models are not affected.',
      confirmLabel: 'Delete all',
    );
    if (!confirmed) return;
    await DatabaseService().deleteAllSessions();
    AppRouter.showMessage('All conversations deleted');
  }

  void _showPrivacy() {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    Widget point(IconData icon, String title, String body) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: JemenaiTheme.fontBody(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: JemenaiTheme.fontBody(
                      fontSize: 12.5,
                      color: jc.mutedForeground,
                      lineHeight: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: jc.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (context) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your privacy',
                    style: JemenaiTheme.fontDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  point(
                    Icons.memory,
                    'Inference happens on your device',
                    'Prompts, images and voice recordings are processed by the '
                        'model running locally. They are never sent to a server.',
                  ),
                  point(
                    Icons.storage,
                    'Conversations are stored locally',
                    'Chats live in a database inside the app. Delete them any '
                        'time from Settings, or by uninstalling the app.',
                  ),
                  point(
                    Icons.cloud_download_outlined,
                    'The internet is used only for downloads',
                    'OffRoad connects to Hugging Face to download models you '
                        'choose. If you add an access token it is sent only to '
                        'Hugging Face, to authorise those downloads.',
                  ),
                  point(
                    Icons.visibility_off_outlined,
                    'No accounts, analytics or tracking',
                    'There is no sign-in, telemetry or advertising SDK.',
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

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
                  sub:
                      'GPU is faster on most phones. Applies the next time a model loads.',
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
                  sub: 'All data stays on-device · tap for details',
                  onTap: _showPrivacy,
                ),
                _buildNavRow(
                  icon: Icons.delete_sweep_outlined,
                  iBg: const Color(0xFF2A0A0A),
                  iColor: const Color(0xFFF87171),
                  title: 'Delete All Conversations',
                  sub: 'Permanently erase chat history on this device',
                  onTap: _deleteAllChats,
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
                  sub: _version ?? 'Private local AI',
                  showChevron: false,
                ),
                _buildNavRow(
                  icon: Icons.smartphone,
                  iBg: const Color(0xFF1A1A2E),
                  iColor: const Color(0xFF6366F1),
                  title: 'Device',
                  sub: _device ?? '…',
                  showChevron: false,
                ),
                _buildNavRow(
                  icon: Icons.info_outline,
                  iBg: const Color(0xFF1A1A2E),
                  iColor: const Color(0xFF6366F1),
                  title: 'Terms & Privacy Policy',
                  sub: 'How OffRoad handles your data',
                  onTap: _showPrivacy,
                ),
              ],
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
            activeTrackColor: theme.colorScheme.primary,
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
