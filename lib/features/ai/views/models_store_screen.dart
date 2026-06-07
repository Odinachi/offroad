import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/theme.dart';

class ModelsStoreScreen extends StatefulWidget {

  const ModelsStoreScreen({
    super.key,
  });

  @override
  State<ModelsStoreScreen> createState() => _ModelsStoreScreenState();
}

class AIModel {
  final String id;
  final String name;
  final String maker;
  final String specialty;
  final String description;
  final double sizeGB;
  final int ramGB;
  final String speed; // 'Fast' | 'Medium' | 'Slow'
  final int iq;
  final List<String> compat;
  final String category;
  final List<String> tags;
  final bool popular;

  AIModel({
    required this.id,
    required this.name,
    required this.maker,
    required this.specialty,
    required this.description,
    required this.sizeGB,
    required this.ramGB,
    required this.speed,
    required this.iq,
    required this.compat,
    required this.category,
    required this.tags,
    this.popular = false,
  });
}

class _ModelsStoreScreenState extends State<ModelsStoreScreen> {
  String _activeCategory = "All";
  String _searchQuery = "";
  final _searchController = TextEditingController();

  final Set<String> _downloaded = {"llama-3.2-3b", "phi-3-mini"};
  final Set<String> _downloading = {"mistral-7b"};
  final Map<String, double> _progress = {"mistral-7b": 68.0};
  final Set<String> _expandedCompat = {};

  Timer? _downloadTimer;

  final List<AIModel> _models = [
    AIModel(
      id: "llama-3.2-3b",
      name: "Llama 3.2 3B",
      maker: "Meta",
      specialty: "General Assistant",
      description:
          "Meta's compact powerhouse. Excellent for everyday tasks, Q&A, and conversation with a surprisingly large context window.",
      sizeGB: 2.0,
      ramGB: 3,
      speed: "Fast",
      iq: 82,
      compat: ["iPhone 14+", "Pixel 7+", "Galaxy S23+"],
      category: "General",
      tags: ["Chat", "Q&A", "Writing"],
      popular: true,
    ),
    AIModel(
      id: "phi-3-mini",
      name: "Phi-3 Mini",
      maker: "Microsoft",
      specialty: "Coding & Reasoning",
      description:
          "Microsoft's reasoning powerhouse. Exceptional for code generation, debugging, and logical tasks in a tiny package.",
      sizeGB: 1.8,
      ramGB: 2,
      speed: "Fast",
      iq: 85,
      compat: ["iPhone 13+", "Android 12+"],
      category: "Coding",
      tags: ["Code", "Logic", "Math"],
      popular: true,
    ),
    AIModel(
      id: "gemma-2b",
      name: "Gemma 2B",
      maker: "Google",
      specialty: "Creative Writing",
      description:
          "Google's creative writing model. Excellent for storytelling, poetry, and imaginative brainstorming tasks.",
      sizeGB: 1.4,
      ramGB: 2,
      speed: "Fast",
      iq: 78,
      compat: ["All devices"],
      category: "Creative",
      tags: ["Writing", "Stories", "Poetry"],
    ),
    AIModel(
      id: "mistral-7b",
      name: "Mistral 7B",
      maker: "Mistral",
      specialty: "Advanced Reasoning",
      description:
          "European AI powerhouse. Exceptional multilingual reasoning, analysis, and instruction-following with superior context.",
      sizeGB: 4.1,
      ramGB: 6,
      speed: "Medium",
      iq: 91,
      compat: ["iPhone 15 Pro", "Pixel 8 Pro", "S24+"],
      category: "Advanced",
      tags: ["Analysis", "Research", "ML"],
      popular: true,
    ),
    AIModel(
      id: "llama-3.1-8b",
      name: "Llama 3.1 8B",
      maker: "Meta",
      specialty: "General + Code",
      description:
          "The most capable Llama model for on-device. Handles complex reasoning, long context, and technical tasks beautifully.",
      sizeGB: 4.7,
      ramGB: 8,
      speed: "Medium",
      iq: 88,
      compat: ["iPhone 15 Pro", "Pixel 8 Pro"],
      category: "General",
      tags: ["Chat", "Code", "Long Context"],
    ),
    AIModel(
      id: "codegemma-7b",
      name: "CodeGemma 7B",
      maker: "Google",
      specialty: "Code Generation",
      description:
          "Dedicated code assistant. Auto-complete, generation, and multi-language explanation across 20+ programming languages.",
      sizeGB: 3.9,
      ramGB: 5,
      speed: "Medium",
      iq: 87,
      compat: ["iPhone 15", "Android 13+"],
      category: "Coding",
      tags: ["Code", "Autocomplete", "Debug"],
    ),
    AIModel(
      id: "tinyllama-1b",
      name: "TinyLlama 1.1B",
      maker: "Community",
      specialty: "Ultra-Lightweight",
      description:
          "Tiny but capable. Perfect for older devices or when battery life and response speed matter more than raw capability.",
      sizeGB: 0.6,
      ramGB: 1,
      speed: "Fast",
      iq: 65,
      compat: ["All devices"],
      category: "Lightweight",
      tags: ["Fast", "Battery", "Compact"],
    ),
    AIModel(
      id: "stablelm-3b",
      name: "StableLM 3B",
      maker: "Stability",
      specialty: "Instruction",
      description:
          "Excellent at following complex multi-step instructions and producing clean, structured outputs for business workflows.",
      sizeGB: 1.8,
      ramGB: 3,
      speed: "Fast",
      iq: 79,
      compat: ["iPhone 13+", "Android 11+"],
      category: "General",
      tags: ["Instructions", "Summary", "Structured"],
    ),
  ];

  final List<String> _categories = [
    "All",
    "General",
    "Coding",
    "Creative",
    "Advanced",
    "Lightweight",
  ];

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
    final foreColor = JemenaiTheme.foreground(widget.isDark);
    final mutedFore = JemenaiTheme.mutedForeground(widget.isDark);
    final cardBg = JemenaiTheme.card(widget.isDark);
    final border = JemenaiTheme.border(widget.isDark);

    // Filter models
    final filteredModels =
        _models.where((model) {
          if (_activeCategory != "All" && model.category != _activeCategory)
            return false;
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final matchesName = model.name.toLowerCase().contains(query);
            final matchesSpecialty = model.specialty.toLowerCase().contains(
              query,
            );
            return matchesName || matchesSpecialty;
          }
          return true;
        }).toList();

    // Calculate total downloaded sizes
    double totalGB = 0;
    for (var id in _downloaded) {
      final model = _models.firstWhere((m) => m.id == id);
      totalGB += model.sizeGB;
    }

    return Container(
      color: JemenaiTheme.background(widget.isDark),
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
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                  color: mutedFore,
                ),
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
                fillColor: JemenaiTheme.muted(widget.isDark),
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

          // Horizontal Categories Bar
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _activeCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => _activeCategory = cat),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: isSelected ? JemenaiTheme.gradBrand : null,
                        color:
                            isSelected
                                ? null
                                : JemenaiTheme.muted(widget.isDark),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow:
                            isSelected
                                ? JemenaiTheme.glowSm(widget.isDark)
                                : [],
                      ),
                      child: Text(
                        cat,
                        style: JemenaiTheme.fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : mutedFore,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Models List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: filteredModels.length,
              itemBuilder: (context, index) {
                final model = filteredModels[index];
                final isDl = _downloaded.contains(model.id);
                final isDling = _downloading.contains(model.id);
                final prog = _progress[model.id] ?? 0;
                final iqDetails = _getIQDetails(model.iq);
                final speedStyle = _getSpeedStyle(model.speed);
                final isExpanded = _expandedCompat.contains(model.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isDling
                                ? JemenaiTheme.jmIndigo(
                                  widget.isDark,
                                ).withOpacity(0.3)
                                : border,
                      ),
                      boxShadow:
                          isDling
                              ? JemenaiTheme.glowSm(widget.isDark)
                              : JemenaiTheme.shadowCard(widget.isDark),
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
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient:
                                          isDl ? JemenaiTheme.gradBrand : null,
                                      color:
                                          isDl
                                              ? null
                                              : JemenaiTheme.muted(
                                                widget.isDark,
                                              ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      isDl
                                          ? Icons.auto_awesome
                                          : Icons.psychology,
                                      color: isDl ? Colors.white : mutedFore,
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
                                                      widget.isDark
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
                                                    color: JemenaiTheme.primary(
                                                      widget.isDark,
                                                    ),
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
                                            color: JemenaiTheme.primary(
                                              widget.isDark,
                                            ),
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
                                  color: JemenaiTheme.mutedForeground(
                                    widget.isDark,
                                  ),
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
                                    '${model.sizeGB} GB',
                                    foreColor,
                                  ),
                                  _buildStatPill(
                                    Icons.memory,
                                    '${model.ramGB} GB RAM',
                                    foreColor,
                                  ),
                                  // Speed style
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: speedStyle['bg'] as Color,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: speedStyle['border'] as Color,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.flash_on,
                                          size: 12,
                                          color: speedStyle['text'] as Color,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          model.speed,
                                          style: JemenaiTheme.fontBody(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: speedStyle['text'] as Color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Offline
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: JemenaiTheme.secondary(
                                        widget.isDark,
                                      ),
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
                                      color: JemenaiTheme.secondary(
                                        widget.isDark,
                                      ),
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
                                        color: JemenaiTheme.secondary(
                                          widget.isDark,
                                        ),
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
                                              color: JemenaiTheme.secondary(
                                                widget.isDark,
                                              ),
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
                              color: JemenaiTheme.secondary(widget.isDark),
                              border: Border(top: BorderSide(color: border)),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  model.compat.map((device) {
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
                                              color: JemenaiTheme.foreground(
                                                widget.isDark,
                                              ),
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
            color: JemenaiTheme.destructive(widget.isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.delete_outline,
            size: 16,
            color: JemenaiTheme.destructive(widget.isDark),
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
            color: JemenaiTheme.secondary(widget.isDark),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.pause,
            size: 16,
            color: JemenaiTheme.foreground(widget.isDark),
          ),
        ),
      );
    }

    // Download option
    final text =
        model.sizeGB < 1
            ? '${(model.sizeGB * 1000).toStringAsFixed(0)} MB'
            : '${model.sizeGB} GB';

    return InkWell(
      onTap: () => _startDownload(model.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: JemenaiTheme.gradBrand,
          borderRadius: BorderRadius.circular(12),
          boxShadow: JemenaiTheme.glowSm(widget.isDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              text,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: JemenaiTheme.secondary(widget.isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: JemenaiTheme.mutedForeground(widget.isDark),
          ),
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
