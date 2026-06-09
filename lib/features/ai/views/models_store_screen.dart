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
      url:
          "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/blob/main/gemma-4-E2B-it.litertlm",
      name: "Gemma 4 E2B",
      maker: "Google",
      specialty: "Multimodal Assistant",
      description:
          "Google's edge-optimised MoE model with 2B effective parameters. Natively understands text, images, and audio on-device. Supports function calling, a 128K context window, and speculative decoding via Multi-Token Prediction.",
      sizeMb: 2590,
      ramGB: 3,
      compactibility: [
        "iPhone 14+",
        "Pixel 7+",
        "Galaxy S23+",
        "Galaxy A54+",
        "OnePlus 11+",
        "Xiaomi 13+",
        "Nothing Phone 2+",
        "Motorola Edge 40+",
      ],
      capabilities: ["Vision", "Audio", "Function Calling", "Thinking"],
    ),
    AIModel(
      url:
          "https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/blob/main/gemma-4-E4B-it.litertlm",
      name: "Gemma 4 E4B",
      maker: "Google",
      specialty: "Multimodal Assistant",
      description:
          "The larger of Google's Gemma 4 edge pair, with 4B effective parameters for stronger reasoning and more accurate function calling. Handles text, image, and audio input with a 128K context window. Best suited to flagship devices.",
      sizeMb: 3660,
      ramGB: 6,
      compactibility: [
        "iPhone 15+",
        "Pixel 8+",
        "Galaxy S24+",
        "Galaxy S23 Ultra",
        "OnePlus 12+",
        "Xiaomi 14+",
        "ASUS ROG Phone 7+",
        "Sony Xperia 1 V+",
      ],
      capabilities: ["Vision", "Audio", "Function Calling", "Thinking"],
    ),
    AIModel(
      url:
          "https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/blob/main/gemma-3n-E2B-it-int4.task",
      name: "Gemma 3n E2B",
      maker: "Google",
      specialty: "Multimodal Assistant",
      description:
          "Google's Gemma 3n with selective parameter activation — runs at an effective 2B footprint while carrying 5B total parameters. Supports text, image, video, and audio input across 140+ languages. Uses Matformer architecture for nested model sizing.",
      sizeMb: 3140,
      ramGB: 2,
      compactibility: [
        "iPhone 14+",
        "Pixel 7+",
        "Galaxy S23+",
        "Galaxy A54+",
        "OnePlus 11+",
        "Xiaomi 13+",
        "Nothing Phone 2+",
        "Motorola Edge 40+",
        "Realme GT 5+",
      ],
      capabilities: ["Vision", "Audio", "Video"],
    ),
    AIModel(
      url:
          "https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/blob/main/gemma-3n-E4B-it-int4.task",
      name: "Gemma 3n E4B",
      maker: "Google",
      specialty: "Multimodal Assistant",
      description:
          "Gemma 3n's larger edge variant, with 4B effective parameters drawn from an 8B total model. Full multimodal input (text, image, video, audio), 140+ language support, and the Matformer nested-model architecture for flexible on-device deployment.",
      sizeMb: 6500,
      ramGB: 3,
      compactibility: [
        "iPhone 15+",
        "Pixel 8+",
        "Galaxy S24+",
        "Galaxy S23 Ultra",
        "OnePlus 12+",
        "Xiaomi 14+",
        "ASUS ROG Phone 7+",
        "Sony Xperia 1 V+",
      ],
      capabilities: ["Vision", "Audio", "Video"],
    ),
    AIModel(
      url:
          "https://huggingface.co/litert-community/Gemma3-1B-IT/blob/main/Gemma3-1B-IT_seq128_q8_ekv1280.task",
      name: "Gemma3 1B",
      maker: "Google",
      specialty: "General Assistant",
      description:
          "Google's compact Gemma 3 text model with 1B parameters, trained on 2 trillion tokens with a 32K context window. Text-only, optimised for low-latency Q&A, summarisation, and instruction following on resource-constrained hardware.",
      sizeMb: 1020,
      ramGB: 2,
      compactibility: [
        "iPhone 14+",
        "Pixel 7+",
        "Galaxy S22+",
        "Galaxy A53+",
        "OnePlus 10+",
        "Xiaomi 12+",
        "Nothing Phone 1+",
        "Motorola Edge 30+",
        "Realme GT 2+",
        "Vivo V27+",
      ],
      capabilities: ["Multilingual"],
    ),
    AIModel(
      url:
          "https://huggingface.co/litert-community/gemma-3-270m-it/blob/main/gemma3-270m-it-q8.litertlm",
      name: "Gemma3 270M",
      maker: "Google",
      specialty: "On-Device Inference",
      description:
          "Google's smallest Gemma 3 model at 270M parameters, over-trained on 6 trillion tokens for surprisingly strong instruction following. Text-only with a 32K context window. Runs at INT4 with minimal quality loss — uses under 0.75% battery for 25 conversations on Pixel 9 Pro.",
      sizeMb: 300,
      ramGB: 1,
      compactibility: [
        "iPhone 12+",
        "Pixel 6+",
        "Galaxy S21+",
        "Galaxy A33+",
        "OnePlus 9+",
        "Xiaomi 11+",
        "Nothing Phone 1+",
        "Motorola Edge 20+",
        "Realme 9 Pro+",
        "Vivo V23+",
        "OPPO Reno 8+",
        "Tecno Camon 20+",
        "Infinix Note 30+",
      ],
      capabilities: ["Multilingual"],
    ),
    AIModel(
      url:
          "https://huggingface.co/sasha-denisov/function-gemma-270M-it/blob/main/functiongemma-270M-it.litertlm",
      name: "FunctionGemma 270M",
      maker: "Google",
      specialty: "Function Calling",
      description:
          "Google's smallest dedicated function-calling model, built on Gemma 3 270M and fine-tuned to map natural language to structured API actions. Not a general chat model — designed as a fine-tuning base for on-device agents. Achieves ~58% accuracy out-of-the-box, up to ~85% after task-specific fine-tuning.",
      sizeMb: 270,
      ramGB: 1,
      compactibility: [
        "iPhone 12+",
        "Pixel 6+",
        "Galaxy S21+",
        "Galaxy A33+",
        "OnePlus 9+",
        "Xiaomi 11+",
        "Nothing Phone 1+",
        "Motorola Edge 20+",
        "Realme 9 Pro+",
        "Vivo V23+",
        "OPPO Reno 8+",
        "Tecno Camon 20+",
        "Infinix Note 30+",
      ],
      capabilities: ["Function Calling"],
    ),
    AIModel(
      url:
          "https://huggingface.co/litert-community/Qwen3-0.6B/blob/main/Qwen3-0.6B.litertlm",
      name: "Qwen3 0.6B",
      maker: "Alibaba",
      specialty: "Reasoning Assistant",
      description:
          "Alibaba's 0.6B dense model from the Qwen3 series, trained on 36 trillion tokens across 119 languages. Uniquely supports both a 'thinking' mode for step-by-step reasoning and a 'non-thinking' mode for fast chat, switchable per query. 32K context window.",
      sizeMb: 586,
      ramGB: 1,
      compactibility: [
        "iPhone 12+",
        "Pixel 6+",
        "Galaxy S21+",
        "Galaxy A33+",
        "OnePlus 9+",
        "Xiaomi 11+",
        "Nothing Phone 1+",
        "Motorola Edge 20+",
        "Realme 9 Pro+",
        "Vivo V23+",
        "OPPO Reno 8+",
        "Tecno Camon 20+",
        "Infinix Note 30+",
      ],
      capabilities: ["Thinking", "Multilingual", "Function Calling"],
    ),
    AIModel(
      url:
          "https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/blob/main/Qwen2.5-1.5B-Instruct_seq128_q8_ekv1280.tflite",
      name: "Qwen2.5 1.5B Instruct",
      maker: "Alibaba",
      specialty: "General Assistant",
      description:
          "Alibaba's 1.5B instruction-tuned model from the Qwen2.5 series. Strong at coding, maths, and structured output (JSON). Supports 29+ languages, long-text generation over 8K tokens, and a 32K context window. A reliable mid-range edge model.",
      sizeMb: 1570,
      ramGB: 4,
      compactibility: [
        "iPhone 13+",
        "Pixel 7+",
        "Galaxy S22+",
        "Galaxy A54+",
        "OnePlus 10+",
        "Xiaomi 12+",
        "Nothing Phone 2+",
        "Motorola Edge 30+",
        "Realme GT 2+",
        "Vivo V27+",
        "OPPO Reno 10+",
      ],
      capabilities: ["Multilingual", "Code"],
    ),
    AIModel(
      url:
          "https://huggingface.co/litert-community/Qwen2.5-0.5B-Instruct/blob/main/Qwen2.5-0.5B-Instruct_seq128_q8_ekv1280.tflite",
      name: "Qwen2.5 0.5B Instruct",
      maker: "Alibaba",
      specialty: "General Assistant",
      description:
          "Alibaba's smallest Qwen2.5 model at 490M parameters (360M non-embedding). Instruction-tuned for Q&A, summarisation, and basic structured output. Supports 29+ languages and a 32K context window. Ideal for extremely memory-constrained devices.",
      sizeMb: 513,
      ramGB: 1,
      compactibility: [
        "iPhone 12+",
        "Pixel 6+",
        "Galaxy S21+",
        "Galaxy A33+",
        "OnePlus 9+",
        "Xiaomi 11+",
        "Nothing Phone 1+",
        "Motorola Edge 20+",
        "Realme 9 Pro+",
        "Vivo V23+",
        "OPPO Reno 8+",
        "Tecno Camon 20+",
        "Infinix Note 30+",
      ],
      capabilities: ["Multilingual"],
    ),
    AIModel(
      url:
          "https://huggingface.co/litert-community/SmolLM-135M-Instruct/blob/main/SmolLM-135M-Instruct_seq128_q8_ekv1280.tflite",
      name: "SmolLM 135M Instruct",
      maker: "HuggingFace",
      specialty: "On-Device Inference",
      description:
          "HuggingFace's ultra-compact 135M model from the SmolLM series, trained on the curated SmolLM-Corpus of synthetic textbooks and code. English-focused with a 2K context window. Suited for simple instruction following, text completion, and classification in memory-critical environments.",
      sizeMb: 148,
      ramGB: 1,
      compactibility: [
        "iPhone 12+",
        "Pixel 6+",
        "Galaxy S21+",
        "Galaxy A33+",
        "OnePlus 9+",
        "Xiaomi 11+",
        "Nothing Phone 1+",
        "Motorola Edge 20+",
        "Realme 9 Pro+",
        "Vivo V23+",
        "OPPO Reno 8+",
        "Tecno Camon 20+",
        "Infinix Note 30+",
      ],
      capabilities: [],
    ),
    AIModel(
      url:
          "https://huggingface.co/litert-community/Phi-4-mini-instruct/blob/main/Phi-4-mini-instruct_multi-prefill-seq_q8_ekv4096.litertlm",
      name: "Phi-4-mini-instruct",
      maker: "Microsoft",
      specialty: "Reasoning & Coding",
      description:
          "Microsoft's 3.8B dense model built on high-quality synthetic data, optimised for reasoning, maths, and code. Features function calling, a 128K context window, and strong multilingual support across 20+ languages. One of the most capable models at this parameter count.",
      sizeMb: 3951,
      ramGB: 4,
      compactibility: [
        "iPhone 14+",
        "Pixel 7+",
        "Galaxy S23+",
        "Galaxy A54+",
        "OnePlus 11+",
        "Xiaomi 13+",
        "Nothing Phone 2+",
        "Motorola Edge 40+",
        "Realme GT 5+",
        "ASUS ROG Phone 7+",
      ],
      capabilities: ["Thinking", "Function Calling", "Multilingual", "Code"],
    ),
    AIModel(
      url:
          "https://huggingface.co/litert-community/DeepSeek-R1-Distill-Qwen-1.5B/blob/main/DeepSeek-R1-Distill-Qwen-1.5B_multi-prefill-seq_q8_ekv4096.litertlm",
      name: "DeepSeek R1 Distill Qwen 1.5B",
      maker: "DeepSeek",
      specialty: "Reasoning",
      description:
          "DeepSeek's 1.5B reasoning model, distilled from the full DeepSeek-R1 using chain-of-thought training data. Based on Qwen2.5-Math-1.5B and inherits strong maths and logical reasoning. Supports a 128K context window. Produces extended reasoning traces before answering.",
      sizeMb: 1830,
      ramGB: 4,
      compactibility: [
        "iPhone 13+",
        "Pixel 7+",
        "Galaxy S22+",
        "Galaxy A54+",
        "OnePlus 10+",
        "Xiaomi 12+",
        "Nothing Phone 2+",
        "Motorola Edge 30+",
        "Realme GT 2+",
        "Vivo V27+",
        "OPPO Reno 10+",
      ],
      capabilities: ["Thinking"],
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
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final foreColor = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;
    final cardBg = jc.card;
    final border = jc.border;

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
                        color: isSelected ? null : jc.muted,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow:
                            isSelected ? JemenaiTheme.glowSm(isDark) : [],
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
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
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient:
                                          isDl ? JemenaiTheme.gradBrand : null,
                                      color: isDl ? null : jc.muted,
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
          boxShadow: JemenaiTheme.glowSm(isDark),
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
