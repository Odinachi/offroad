import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jemenai/services/cache_service.dart';
import 'package:jemenai/shared/theme.dart';

class HuggingFaceTokenScreen extends StatefulWidget {
  const HuggingFaceTokenScreen({super.key});

  @override
  State<HuggingFaceTokenScreen> createState() => _HuggingFaceTokenScreenState();
}

class _HuggingFaceTokenScreenState extends State<HuggingFaceTokenScreen> {
  final _tokenController = TextEditingController();
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    final savedToken = CacheService.instance.getHuggingFaceToken();
    if (savedToken != null) {
      _tokenController.text = savedToken;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _saveToken() async {
    final token = _tokenController.text.trim();
    await CacheService.instance.saveHuggingFaceToken(token);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hugging Face Token saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _tokenController.text = data.text!;
      });
    }
  }

  void _showInfoModal() {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: jc.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: jc.border),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: jc.border,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Setup Instructions',
                style: JemenaiTheme.fontDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Follow these steps to generate and authorize your token.',
                style: JemenaiTheme.fontBody(
                  fontSize: 12,
                  color: jc.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),

              _buildStepRow(
                step: '1',
                title: 'Create an Account',
                description:
                    'Visit huggingface.co and create a new account, or sign in.',
              ),
              _buildStepRow(
                step: '2',
                title: 'Generate Token',
                description:
                    'Go to Settings -> Access Tokens and generate a new token with "Read" access.',
              ),
              _buildStepRow(
                step: '3',
                title: 'Request Model Access',
                description:
                    'Search for your desired model (e.g., google/gemma-2b-it) and accept the User License Agreement if required.',
              ),

              const SizedBox(height: 32),

              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: JemenaiTheme.gradBrand,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: JemenaiTheme.glowSm(isDark),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'I Understand',
                    style: JemenaiTheme.fontBody(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepRow({
    required String step,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final jc = theme.jColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: JemenaiTheme.gradBrand,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: JemenaiTheme.fontBody(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: JemenaiTheme.fontBody(
                    fontSize: 12,
                    color: jc.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'HuggingFace',
          style: JemenaiTheme.fontDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: foreColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showInfoModal,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium Icon Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: jc.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: jc.border),
                boxShadow: JemenaiTheme.shadowCard(isDark),
              ),
              child: Column(
                children: [
                  Text(
                    'HuggingFace Access Token',
                    style: JemenaiTheme.fontDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: foreColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This token allows your device to securely authenticate and fetch local AI models. All downloads are directly stored on your hardware.',
                    textAlign: TextAlign.center,
                    style: JemenaiTheme.fontBody(
                      fontSize: 12,
                      color: mutedFore,
                      lineHeight: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Token input title
            Text(
              'Access Token',
              style: JemenaiTheme.fontDisplay(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: foreColor,
              ),
            ),
            const SizedBox(height: 10),

            // TextField with Custom styling
            TextField(
              controller: _tokenController,
              obscureText: _obscureToken,
              style: JemenaiTheme.fontBody(fontSize: 14, color: foreColor),
              decoration: InputDecoration(
                hintText: 'Paste hf_... token',
                hintStyle: JemenaiTheme.fontBody(
                  fontSize: 14,
                  color: mutedFore,
                ),
                filled: true,
                fillColor: jc.muted,
                contentPadding: const EdgeInsets.all(18),
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
                    color: theme.colorScheme.primary.withOpacity(0.25),
                    width: 2,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.content_paste_rounded),
                      iconSize: 18,
                      color: mutedFore,
                    ),
                    IconButton(
                      onPressed:
                          () => setState(() => _obscureToken = !_obscureToken),
                      icon: Icon(
                        _obscureToken
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 18,
                        color: mutedFore,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Security Disclaimer Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF022016).withOpacity(isDark ? 0.4 : 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF4ADE80).withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF4ADE80),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Stored locally. Credentials never leave your device.',
                      style: JemenaiTheme.fontBody(
                        fontSize: 11,
                        color: const Color(0xFF4ADE80),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save button with gradient & glow
            InkWell(
              onTap: _saveToken,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: JemenaiTheme.gradBrand,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: JemenaiTheme.glowSm(isDark),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Save Token',
                  style: JemenaiTheme.fontBody(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
