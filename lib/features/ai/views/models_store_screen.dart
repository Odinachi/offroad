import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jemenai/features/ai/model/ai_model.dart';
import 'package:jemenai/features/ai/view_models/model_download_cubit.dart';
import '../../../shared/theme.dart';

class ModelsStoreScreen extends StatefulWidget {
  const ModelsStoreScreen({super.key});

  @override
  State<ModelsStoreScreen> createState() => _ModelsStoreScreenState();
}

class _ModelsStoreScreenState extends State<ModelsStoreScreen> {
  String _searchQuery = "";
  final _searchController = TextEditingController();
  final Set<String> _expandedCompat = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getIQDetails(int iq) {
    if (iq >= 88) return {'label': 'Elite', 'color': const Color(0xFF818CF8)};
    if (iq >= 80)
      return {'label': 'Advanced', 'color': const Color(0xFF60A5FA)};
    if (iq >= 70) return {'label': 'Capable', 'color': const Color(0xFF34D399)};
    return {'label': 'Basic', 'color': const Color(0xFFFBBF24)};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;
    final border = jc.border;

    return BlocBuilder<ModelDownloadCubit, ModelDownloadState>(
      builder: (context, downloadState) {
        final cubit = context.read<ModelDownloadCubit>();

        // Resolve statuses map
        final statuses = downloadState is ModelDownloadUpdated
            ? downloadState.statuses
            : <String, ModelDownloadStatus>{};

        // Count installed and total size
        int downloadedCount = 0;
        double totalGB = 0;
        for (final model in models) {
          final status = statuses[model.id];
          if (status != null && status.phase == DownloadPhase.installed) {
            downloadedCount++;
            totalGB += model.sizeGB;
          }
        }

        // Filter models
        final filteredModels = models.where((model) {
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final matchesName = model.name.toLowerCase().contains(query);
            final matchesSpecialty =
                model.specialty.toLowerCase().contains(query);
            final matchesCompany = model.maker.toLowerCase().contains(query);
            return matchesName || matchesSpecialty || matchesCompany;
          }
          return true;
        }).toList();

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
                      '$downloadedCount downloaded · ${totalGB.toStringAsFixed(1)} GB used',
                      style:
                          JemenaiTheme.fontBody(fontSize: 12, color: mutedFore),
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
                    suffixIcon: _searchQuery.isNotEmpty
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
                    final status = statuses[model.id] ??
                        const ModelDownloadStatus();
                    final isDl = status.phase == DownloadPhase.installed;
                    final isDling = status.phase == DownloadPhase.downloading;
                    final isFailed = status.phase == DownloadPhase.failed;
                    final prog = status.progress.toDouble();
                    final iqDetails = _getIQDetails(model.iq);
                    final isExpanded = _expandedCompat.contains(model.id);
                    final cardBg = jc.card;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDling
                                ? jc.jmIndigo.withOpacity(0.3)
                                : border,
                          ),
                          boxShadow: isDling
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              gradient: isDl
                                                  ? JemenaiTheme.gradBrand
                                                  : null,
                                              color: isDl ? null : jc.muted,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              isDl
                                                  ? Icons.auto_awesome
                                                  : Icons.psychology,
                                              color: isDl
                                                  ? Colors.white
                                                  : mutedFore,
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
                                                  style:
                                                      JemenaiTheme.fontBody(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: foreColor,
                                                  ),
                                                ),
                                                if (model.popular)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: isDark
                                                          ? JemenaiTheme
                                                              .gradSubtleDark
                                                          : JemenaiTheme
                                                              .gradSubtleLight,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      'Popular',
                                                      style: JemenaiTheme
                                                          .fontBody(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                if (isDl)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF022016,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFF4ADE80,
                                                        ).withOpacity(0.2),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '✓ Ready',
                                                      style: JemenaiTheme
                                                          .fontBody(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                color:
                                                    theme.colorScheme.primary,
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
                                        status,
                                        cubit,
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                              color:
                                                  iqDetails['color'] as Color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          height: 6,
                                          width: double.infinity,
                                          alignment: Alignment.centerLeft,
                                          color: jc.secondaryFill,
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: model.iq / 100,
                                            child: Container(
                                              color:
                                                  iqDetails['color'] as Color,
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
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Container(
                                            height: 6,
                                            width: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            color: jc.secondaryFill,
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: prog / 100,
                                              child: Container(
                                                decoration:
                                                    const BoxDecoration(
                                                  gradient:
                                                      JemenaiTheme.gradBrand,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  // Failed state
                                  if (isFailed) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 14,
                                            color: theme.colorScheme.error,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Download failed. Tap to retry.',
                                              style: JemenaiTheme.fontBody(
                                                fontSize: 11,
                                                color: theme.colorScheme.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),

                                  // Bottom bar: Tags & Compat Toggle
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: model.tags.map((t) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                right: 0,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (isExpanded) {
                                              _expandedCompat
                                                  .remove(model.id);
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
                                  border: Border(
                                      top: BorderSide(color: border)),
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
                                        borderRadius:
                                            BorderRadius.circular(12),
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
                                              color: theme
                                                  .colorScheme.onSurface,
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
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    AIModel model,
    ModelDownloadCubit cubit,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            'Delete Model',
            style: JemenaiTheme.fontDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${model.name}? You will need to download it again to use it.',
            style: JemenaiTheme.fontBody(
              fontSize: 14,
              color: theme.jColors.mutedForeground,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: JemenaiTheme.fontBody(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cubit.deleteModel(model);
              },
              child: Text(
                'Delete',
                style: JemenaiTheme.fontBody(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    AIModel model,
    ModelDownloadStatus status,
    ModelDownloadCubit cubit,
  ) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    switch (status.phase) {
      case DownloadPhase.installed:
        return InkWell(
          onTap: () => _confirmDelete(context, model, cubit),
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

      case DownloadPhase.downloading:
        return InkWell(
          onTap: () => cubit.cancelDownload(model.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: jc.secondaryFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.close,
              size: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
        );

      case DownloadPhase.failed:
        return InkWell(
          onTap: () => cubit.startDownload(model),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 13, color: theme.colorScheme.error),
                const SizedBox(width: 4),
                Text(
                  'Retry',
                  style: JemenaiTheme.fontBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        );

      case DownloadPhase.idle:
        return InkWell(
          onTap: () => cubit.startDownload(model),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
