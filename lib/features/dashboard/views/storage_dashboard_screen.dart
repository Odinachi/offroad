import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../shared/theme.dart';

class StorageDashboardScreen extends StatefulWidget {
  final Function(String, [Map<String, dynamic>]) onNavigate;
  final bool isDark;

  const StorageDashboardScreen({
    super.key,
    required this.onNavigate,
    required this.isDark,
  });

  @override
  State<StorageDashboardScreen> createState() => _StorageDashboardScreenState();
}

class _StorageDashboardScreenState extends State<StorageDashboardScreen> {
  // Storage data
  final double _totalGB = 128.0;
  final double _otherGB = 38.4;
  final Set<String> _deleted = {};

  final List<Map<String, dynamic>> _modelsStorage = [
    {'name': "Llama 3.2 3B", 'gb': 2.0, 'color': const Color(0xFF818CF8)},
    {'name': "Phi-3 Mini", 'gb': 1.8, 'color': const Color(0xFFA78BFA)},
    {
      'name': "Mistral 7B*",
      'gb': 2.8,
      'color': const Color(0xFF38BDF8),
      'partial': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final foreColor = JemenaiTheme.foreground(widget.isDark);
    final mutedFore = JemenaiTheme.mutedForeground(widget.isDark);
    final cardBg = JemenaiTheme.card(widget.isDark);
    final border = JemenaiTheme.border(widget.isDark);

    // Filter active items
    final activeModels =
        _modelsStorage.where((m) => !_deleted.contains(m['name'])).toList();

    // Recompute sizes
    final double aiGB = activeModels.fold(
      0.0,
      (acc, m) => acc + (m['gb'] as double),
    );
    final double usedGB = aiGB + _otherGB;
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
      color: JemenaiTheme.background(widget.isDark),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
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
                  boxShadow: JemenaiTheme.shadowCard(widget.isDark),
                ),
                child: Row(
                  children: [
                    // Donut graphic
                    SizedBox(
                      width: 108,
                      height: 108,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(100, 100),
                            painter: DonutChartPainter(
                              pct: usedPct / 100,
                              isDark: widget.isDark,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${usedPct.toStringAsFixed(0)}%',
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
                            color: JemenaiTheme.primary(widget.isDark),
                            isPrimary: true,
                          ),
                          const SizedBox(height: 10),
                          _buildDonutStatRow(
                            label: 'AI Models',
                            valueText: '${aiGB.toStringAsFixed(1)} GB',
                            pct: (aiGB / _totalGB) * 100,
                            color: const Color(0xFF818CF8),
                          ),
                          const SizedBox(height: 10),
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

            // Tips Section
            _buildTipsSection(foreColor, mutedFore),
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
                        ? JemenaiTheme.foreground(widget.isDark)
                        : JemenaiTheme.mutedForeground(widget.isDark),
              ),
            ),
            Text(
              valueText,
              style: JemenaiTheme.fontBody(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: JemenaiTheme.foreground(widget.isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 4.5,
            color: JemenaiTheme.secondary(widget.isDark),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (pct / 100).clamp(0.0, 1.0),
              child: Container(color: color),
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
              boxShadow: JemenaiTheme.shadowCard(widget.isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Horizontal Stacked bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 12,
                    color: JemenaiTheme.secondary(widget.isDark),
                    child:
                        activeModels.isEmpty
                            ? const SizedBox.shrink()
                            : Row(
                              children:
                                  activeModels.map((m) {
                                    final ratio =
                                        totalModelsGB > 0
                                            ? (m['gb'] as double) /
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
                const SizedBox(height: 12),

                // Labels
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children:
                      _modelsStorage.map((m) {
                        final isAct = !_deleted.contains(m['name']);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    isAct
                                        ? (m['color'] as Color)
                                        : mutedFore.withOpacity(0.4),
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
                                color:
                                    isAct
                                        ? foreColor
                                        : mutedFore.withOpacity(0.6),
                                fontWeight:
                                    isAct ? FontWeight.bold : FontWeight.normal,
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
                _modelsStorage.map((m) {
                  final isDel = _deleted.contains(m['name']);
                  if (isDel) return const SizedBox.shrink();

                  final isPartial = m['partial'] as bool? ?? false;
                  final color = m['color'] as Color;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: border),
                        boxShadow: JemenaiTheme.shadowCard(widget.isDark),
                      ),
                      child: Row(
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
                                  '${(m['gb'] as double).toStringAsFixed(1)} GB${isPartial ? " (downloading)" : ""}',
                                  style: JemenaiTheme.fontBody(
                                    fontSize: 11,
                                    color: mutedFore,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _deleted.add(m['name'] as String);
                              });
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: JemenaiTheme.destructive(widget.isDark),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: JemenaiTheme.destructive(
                                widget.isDark,
                              ).withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
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

  Widget _buildTipsSection(Color foreColor, Color mutedFore) {
    return Column(
      children: [
        // Tip 1: Optimize Storage
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: JemenaiTheme.card(widget.isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: JemenaiTheme.border(widget.isDark)),
              boxShadow: JemenaiTheme.shadowCard(widget.isDark),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_down,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Optimize Storage',
                        style: JemenaiTheme.fontBody(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: foreColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'TinyLlama (600 MB) offers a 4x storage saving over larger models for everyday tasks.',
                        style: JemenaiTheme.fontBody(
                          fontSize: 11,
                          color: JemenaiTheme.mutedForeground(widget.isDark),
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => widget.onNavigate('models', {}),
                        child: Text(
                          'Explore lightweight models →',
                          style: JemenaiTheme.fontBody(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: JemenaiTheme.primary(widget.isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tip 2: Before you download
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: JemenaiTheme.card(widget.isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: JemenaiTheme.border(widget.isDark)),
              boxShadow: JemenaiTheme.shadowCard(widget.isDark),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Before You Download',
                        style: JemenaiTheme.fontBody(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: foreColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Check storage impact before committing to a large model download.',
                        style: JemenaiTheme.fontBody(
                          fontSize: 11,
                          color: JemenaiTheme.mutedForeground(widget.isDark),
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => widget.onNavigate('models', {}),
                        child: Text(
                          'Browse models →',
                          style: JemenaiTheme.fontBody(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: JemenaiTheme.primary(widget.isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
