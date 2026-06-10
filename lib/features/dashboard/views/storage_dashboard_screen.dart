import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ai/model/ai_model.dart';
import '../../ai/view_models/model_download_cubit.dart';
import '../../../shared/theme.dart';

class StorageDashboardScreen extends StatefulWidget {
  const StorageDashboardScreen({super.key});

  @override
  State<StorageDashboardScreen> createState() => _StorageDashboardScreenState();
}

class _StorageDashboardScreenState extends State<StorageDashboardScreen> {
  // Storage data
  final double _totalGB = 128.0;
  final double _otherGB = 38.4;
  final double _offroadGB = 1.2;

  final List<Color> _modelColors = [
    const Color(0xFF818CF8),
    const Color(0xFFA78BFA),
    const Color(0xFF38BDF8),
    const Color(0xFF10B981),
    const Color(0xFFF43F5E),
    const Color(0xFFF59E0B),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;
    final cardBg = jc.card;
    final border = jc.border;

    final cubit = context.watch<ModelDownloadCubit>();

    final List<Map<String, dynamic>> activeModels = [];
    int colorIndex = 0;

    for (final model in models) {
      final status = cubit.statusFor(model.id);
      if (status.phase == DownloadPhase.installed ||
          status.phase == DownloadPhase.downloading) {
        activeModels.add({
          'model': model,
          'name': model.name,
          'gb': model.sizeGB,
          'color': _modelColors[colorIndex % _modelColors.length],
          'partial': status.phase == DownloadPhase.downloading,
          'progress': status.progress,
        });
        colorIndex++;
      }
    }

    // Recompute sizes
    final double aiGB = activeModels.fold(0.0, (acc, m) {
      if (m['partial'] == true) {
        return acc +
            (m['gb'] as num).toDouble() *
                ((m['progress'] as num?)?.toDouble() ?? 0) /
                100;
      }
      return acc + (m['gb'] as num).toDouble();
    });
    final double usedGB = aiGB + _otherGB + _offroadGB;
    final double freeGB = _totalGB - usedGB;
    final double usedPct = (usedGB / _totalGB) * 100;

    final String health;
    final Color healthColor;
    if (freeGB > 20) {
      health = "Healthy";
      healthColor = const Color(0xFF4ADE80);
    } else if (freeGB > 8) {
      health = "Low";
      healthColor = const Color(0xFFFBBF24);
    } else {
      health = "Critical";
      healthColor = const Color(0xFFF87171);
    }

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storage',
                    style: JemenaiTheme.fontDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: foreColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: healthColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$health · ${freeGB.toStringAsFixed(1)} GB free',
                        style: JemenaiTheme.fontBody(
                          fontSize: 12,
                          color: mutedFore,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Donut Ring Card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 4.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: border),
                  boxShadow: JemenaiTheme.shadowCard(isDark),
                ),
                child: Row(
                  children: [
                    // Donut graphic
                    SizedBox(
                      width: 108,
                      height: 108,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: usedPct),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(100, 100),
                                painter: DonutChartPainter(
                                  pct: val / 100,
                                  isDark: isDark,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${val.toStringAsFixed(0)}%',
                                    style: JemenaiTheme.fontDisplay(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: foreColor,
                                    ),
                                  ),
                                  Text(
                                    'used',
                                    style: JemenaiTheme.fontBody(
                                      fontSize: 10,
                                      color: mutedFore,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Stats progress list
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDonutStatRow(
                            label: 'Used',
                            valueText:
                                '${usedGB.toStringAsFixed(1)} / ${_totalGB.toInt()} GB',
                            pct: usedPct,
                            color: theme.colorScheme.primary,
                            isPrimary: true,
                          ),
                          const SizedBox(height: 8),
                          _buildDonutStatRow(
                            label: 'AI Models',
                            valueText: '${aiGB.toStringAsFixed(1)} GB',
                            pct: (aiGB / _totalGB) * 100,
                            color: const Color(0xFF818CF8),
                          ),
                          const SizedBox(height: 8),
                          _buildDonutStatRow(
                            label: 'Offroad App',
                            valueText: '${_offroadGB.toStringAsFixed(1)} GB',
                            pct: (_offroadGB / _totalGB) * 100,
                            color: const Color(0xFF10B981),
                          ),
                          const SizedBox(height: 8),
                          _buildDonutStatRow(
                            label: 'Other',
                            valueText: '${_otherGB.toStringAsFixed(1)} GB',
                            pct: (_otherGB / _totalGB) * 100,
                            color: mutedFore,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Breakdown
            _buildBreakdownSection(
              activeModels,
              aiGB,
              border,
              cardBg,
              foreColor,
              mutedFore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutStatRow({
    required String label,
    required String valueText,
    required double pct,
    required Color color,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    final jc = theme.jColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: JemenaiTheme.fontBody(
                fontSize: 11,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                color:
                    isPrimary
                        ? theme.colorScheme.onSurface
                        : jc.mutedForeground,
              ),
            ),
            Text(
              valueText,
              style: JemenaiTheme.fontBody(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 4.5,
            color: jc.secondaryFill,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: (pct / 100).clamp(0.0, 1.0),
              ),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: val,
                  child: Container(color: color),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownSection(
    List<Map<String, dynamic>> activeModels,
    double totalModelsGB,
    Color border,
    Color cardBg,
    Color foreColor,
    Color mutedFore,
  ) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Text(
            'Storage Breakdown',
            style: JemenaiTheme.fontDisplay(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: foreColor,
            ),
          ),
        ),

        // Stacked Relative progress bar card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
              boxShadow: JemenaiTheme.shadowCard(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Horizontal Stacked bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 12,
                    color: jc.secondaryFill,
                    child:
                        activeModels.isEmpty
                            ? const SizedBox.shrink()
                            : TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (context, val, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: val,
                                  child: child,
                                );
                              },
                              child: Row(
                                children:
                                    activeModels.map((m) {
                                      final ratio =
                                          totalModelsGB > 0
                                              ? (m['gb'] as num).toDouble() /
                                                  totalModelsGB
                                              : 0;
                                      return Expanded(
                                        flex: (ratio * 1000).toInt().clamp(
                                          1,
                                          1000,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            right: 1.5,
                                          ),
                                          color: m['color'] as Color,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 12),

                // Labels
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children:
                      activeModels.map((m) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: m['color'] as Color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              (m['name'] as String)
                                  .split(' ')
                                  .take(2)
                                  .join(' '),
                              style: JemenaiTheme.fontBody(
                                fontSize: 11,
                                color: foreColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // List of models storage items
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children:
                activeModels.map((m) {
                  final isPartial = m['partial'] as bool? ?? false;
                  final color = m['color'] as Color;
                  final progress = (m['progress'] as num?)?.toDouble() ?? 0.0;
                  final aiModel = m['model'] as AIModel;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                        boxShadow: JemenaiTheme.shadowCard(isDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.flash_on,
                                  color: color,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m['name'] as String,
                                      style: JemenaiTheme.fontBody(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: foreColor,
                                      ),
                                    ),
                                    Text(
                                      '${(m['gb'] as num).toDouble().toStringAsFixed(1)} GB',
                                      style: JemenaiTheme.fontBody(
                                        fontSize: 11,
                                        color: mutedFore,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isPartial) ...[
                                Text(
                                  '${progress.toInt()}%',
                                  style: JemenaiTheme.fontBody(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    context
                                        .read<ModelDownloadCubit>()
                                        .cancelDownload(aiModel.id);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: theme.colorScheme.error,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error
                                        .withOpacity(0.08),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ] else
                                IconButton(
                                  onPressed: () {
                                    context
                                        .read<ModelDownloadCubit>()
                                        .deleteModel(aiModel);
                                  },
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: theme.colorScheme.error,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error
                                        .withOpacity(0.08),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                            ],
                          ),
                          if (isPartial) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                backgroundColor: jc.secondaryFill,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for storage donut circle
class DonutChartPainter extends CustomPainter {
  final double pct;
  final bool isDark;

  DonutChartPainter({required this.pct, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8.0;
    const strokeWidth = 10.0;

    // Background track circle
    final bgPaint =
        Paint()
          ..color = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Active arc painter using linear gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = const SweepGradient(
      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF4F46E5)],
      startAngle: -math.pi / 2,
      endAngle: 1.5 * math.pi,
    );

    final activePaint =
        Paint()
          ..shader = gradient.createShader(rect)
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    // Draw active sector (-90 deg offset)
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * pct, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
