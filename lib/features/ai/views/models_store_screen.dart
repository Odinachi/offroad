import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jemenai/features/ai/model/ai_model.dart';
import '../../../shared/theme.dart';

class ModelsStoreScreen extends StatefulWidget {
  const ModelsStoreScreen({super.key});

  @override
  State<ModelsStoreScreen> createState() => _ModelsStoreScreenState();
}

class _ModelsStoreScreenState extends State<ModelsStoreScreen> {
  String _searchQuery = "";
  final _searchController = TextEditingController();

  final Set<String> _downloaded = {"llama-3.2-3b", "phi-3-mini"};
  final Set<String> _downloading = {"mistral-7b"};
  final Map<String, double> _progress = {"mistral-7b": 68.0};
  final Set<String> _expandedCompat = {};

  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    // Simulate ongoing downloads
    _downloadTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return;
      setState(() {
        final finished = <String>[];
        for (var id in _downloading) {
          final currentProg = _progress[id] ?? 0;
          final nextProg = currentProg + 0.5;
          if (nextProg >= 100) {
            finished.add(id);
          } else {
            _progress[id] = nextProg;
          }
        }

        for (var id in finished) {
          _downloading.remove(id);
          _progress.remove(id);
          _downloaded.add(id);
        }
      });
    });
  }

  @override
  void dispose() {
    _downloadTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getSpeedStyle(String speed) {
    if (speed == "Fast") {
      return {
        'bg': const Color(0xFF022016),
        'text': const Color(0xFF4ADE80),
        'border': const Color(0xFF4ADE80).withOpacity(0.18),
      };
    } else if (speed == "Medium") {
      return {
        'bg': const Color(0xFF1C1400),
        'text': const Color(0xFFFBBF24),
        'border': const Color(0xFFFBBF24).withOpacity(0.18),
      };
    } else {
      return {
        'bg': const Color(0xFF200000),
        'text': const Color(0xFFF87171),
        'border': const Color(0xFFF87171).withOpacity(0.18),
      };
    }
  }

  Map<String, dynamic> _getIQDetails(int iq) {
    if (iq >= 88) return {'label': 'Elite', 'color': const Color(0xFF818CF8)};
    if (iq >= 80)
      return {'label': 'Advanced', 'color': const Color(0xFF60A5FA)};
    if (iq >= 70) return {'label': 'Capable', 'color': const Color(0xFF34D399)};
    return {'label': 'Basic', 'color': const Color(0xFFFBBF24)};
  }

  void _startDownload(String id) {
    setState(() {
      _downloading.add(id);
      _progress[id] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;
    final cardBg = jc.card;
    final border = jc.border;

    // Filter models
    final filteredModels =
        models.where((model) {
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final matchesName = model.name.toLowerCase().contains(query);
            final matchesSpecialty = model.specialty.toLowerCase().contains(
              query,
            );
            final matchesCompany = model.maker.toLowerCase().contains(query);
            return matchesName || matchesSpecialty || matchesCompany;
          }
          return true;
        }).toList();

    // Calculate total downloaded sizes
    double totalGB = 0;
    // for (var id in _downloaded) {
    //   final model = _models.firstWhere((m) => m.id == id);
    //   totalGB += model.sizeGB;
    // }

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Model Store',
                  style: JemenaiTheme.fontDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: foreColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_downloaded.length} downloaded · ${totalGB.toStringAsFixed(1)} GB used',
                  style: JemenaiTheme.fontBody(fontSize: 12, color: mutedFore),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 4.0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: JemenaiTheme.fontBody(fontSize: 14, color: foreColor),
              decoration: InputDecoration(
                hintText: 'Search models...',
                hintStyle: JemenaiTheme.fontBody(
                  fontSize: 14,
                  color: mutedFore,
                ),
                prefixIcon: Icon(Icons.search, size: 16, color: mutedFore),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.close, size: 16, color: mutedFore),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                        : null,
                filled: true,
                fillColor: jc.muted,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Models List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              itemCount: filteredModels.length,
              itemBuilder: (context, index) {
                final model = filteredModels[index];
                final isDl = _downloaded.contains(model.id);
                final isDling = _downloading.contains(model.id);
                final prog = _progress[model.id] ?? 0;
                final iqDetails = _getIQDetails(model.iq);
                final isExpanded = _expandedCompat.contains(model.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDling ? jc.jmIndigo.withOpacity(0.3) : border,
                      ),
                      boxShadow:
                          isDling
                              ? JemenaiTheme.glowSm(isDark)
                              : JemenaiTheme.shadowCard(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: Icon + Title/Makers + Download Button
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  model.image?.image(
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.contain,
                                      ) ??
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient:
                                              isDl
                                                  ? JemenaiTheme.gradBrand
                                                  : null,
                                          color: isDl ? null : jc.muted,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          isDl
                                              ? Icons.auto_awesome
                                              : Icons.psychology,
                                          color:
                                              isDl ? Colors.white : mutedFore,
                                          size: 20,
                                        ),
                                      ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            Text(
                                              model.name,
                                              style: JemenaiTheme.fontBody(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: foreColor,
                                              ),
                                            ),
                                            if (model.popular)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      isDark
                                                          ? JemenaiTheme
                                                              .gradSubtleDark
                                                          : JemenaiTheme
                                                              .gradSubtleLight,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Popular',
                                                  style: JemenaiTheme.fontBody(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .primary,
                                                  ),
                                                ),
                                              ),
                                            if (isDl)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF022016,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFF4ADE80,
                                                    ).withOpacity(0.2),
                                                  ),
                                                ),
                                                child: Text(
                                                  '✓ Ready',
                                                  style: JemenaiTheme.fontBody(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(
                                                      0xFF4ADE80,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          model.specialty,
                                          style: JemenaiTheme.fontBody(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          model.maker,
                                          style: JemenaiTheme.fontBody(
                                            fontSize: 11,
                                            color: mutedFore,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action Button
                                  _buildActionButton(
                                    model,
                                    isDl,
                                    isDling,
                                    prog,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Description
                              Text(
                                model.description,
                                style: JemenaiTheme.fontBody(
                                  fontSize: 12,
                                  color: jc.mutedForeground,
                                  lineHeight: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Stat pills
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _buildStatPill(
                                    Icons.storage,
                                    model.size,
                                    foreColor,
                                  ),
                                  _buildStatPill(
                                    Icons.memory,
                                    '${model.ramGB} GB RAM',
                                    foreColor,
                                  ),
                                  // Offline
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: jc.secondaryFill,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.wifi_off,
                                          size: 12,
                                          color: Color(0xFF4ADE80),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Offline',
                                          style: JemenaiTheme.fontBody(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF4ADE80),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // IQ Intelligence Bar
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Intelligence',
                                        style: JemenaiTheme.fontBody(
                                          fontSize: 11,
                                          color: mutedFore,
                                        ),
                                      ),
                                      Text(
                                        '${iqDetails['label'] as String} · ${model.iq}/100',
                                        style: JemenaiTheme.fontBody(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: iqDetails['color'] as Color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      height: 6,
                                      color: jc.secondaryFill,
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: model.iq / 100,
                                        child: Container(
                                          color: iqDetails['color'] as Color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Download progress bar
                              if (isDling) ...[
                                const SizedBox(height: 12),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Downloading...',
                                          style: JemenaiTheme.fontBody(
                                            fontSize: 11,
                                            color: mutedFore,
                                          ),
                                        ),
                                        Text(
                                          '${prog.toStringAsFixed(0)}%',
                                          style: JemenaiTheme.fontBody(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: foreColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        height: 6,
                                        color: jc.secondaryFill,
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: prog / 100,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              gradient: JemenaiTheme.gradBrand,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),

                              // Bottom bar: Tags & Compat Toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children:
                                        model.tags.map((t) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              right: 6,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: jc.secondaryFill,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              t,
                                              style: JemenaiTheme.fontBody(
                                                fontSize: 10,
                                                color: mutedFore,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isExpanded) {
                                          _expandedCompat.remove(model.id);
                                        } else {
                                          _expandedCompat.add(model.id);
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          'Compat',
                                          style: JemenaiTheme.fontBody(
                                            fontSize: 11,
                                            color: mutedFore,
                                          ),
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          size: 12,
                                          color: mutedFore,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Expanded Compatibility area
                        if (isExpanded)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: jc.secondaryFill,
                              border: Border(top: BorderSide(color: border)),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  model.compactibility.map((device) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: border),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline,
                                            size: 12,
                                            color: Color(0xFF4ADE80),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            device,
                                            style: JemenaiTheme.fontBody(
                                              fontSize: 11,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    AIModel model,
    bool isDl,
    bool isDling,
    double prog,
  ) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    if (isDl) {
      return InkWell(
        onTap: () {
          setState(() {
            _downloaded.remove(model.id);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.delete_outline,
            size: 16,
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    if (isDling) {
      return InkWell(
        onTap: () {
          setState(() {
            _downloading.remove(model.id);
            _progress.remove(model.id);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: jc.secondaryFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.pause,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _startDownload(model.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: JemenaiTheme.gradBrand,
          borderRadius: BorderRadius.circular(12),
          boxShadow: JemenaiTheme.glowSm(isDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              model.size,
              style: JemenaiTheme.fontBody(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String text, Color color) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: jc.secondaryFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: jc.mutedForeground),
          const SizedBox(width: 4),
          Text(
            text,
            style: JemenaiTheme.fontBody(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
