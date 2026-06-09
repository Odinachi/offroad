import 'package:jemenai/shared/assets.dart';

enum AICapability {
  vision('Vision'),
  audio('Audio'),
  video('Video'),
  thinking('Thinking'),
  multilingual('Multilingual'),
  code('Code'),
  functionCalling('Function Calling');

  final String label;
  const AICapability(this.label);
}

enum AIModality {
  text('Text'),
  image('Image'),
  audio('Audio'),
  video('Video');

  final String label;
  const AIModality(this.label);
}

class AIModel {
  final String url;
  final String name;
  final String maker;
  final String specialty;
  final String description;
  final double sizeMb;
  final int ramGB;

  final List<String> compactibility;

  final List<AICapability>? capabilities;
  final bool? requiresAuth;
  final List<AIModality> inputModalities;
  final List<AIModality> outputModalities;
  final ImageAsset? image;

  AIModel({
    required this.url,
    required this.name,
    required this.maker,
    required this.specialty,
    required this.description,
    required this.sizeMb,
    required this.ramGB,
    required this.inputModalities,
    required this.outputModalities,
    required this.compactibility,
    this.capabilities,
    this.requiresAuth,
    this.image,
  });

  String get id => url;
  bool get popular => name.contains('Gemma 4') || name.contains('R1');
  double get sizeGB => sizeMb / 1024;
  int get iq => sizeMb > 3000 ? 90 : (sizeMb > 1000 ? 80 : 70);

  String get size =>
      sizeGB < 1
          ? '${(sizeGB * 1000).toStringAsFixed(0)} MB'
          : '${sizeGB.toStringAsFixed(1)} GB';
  List<String> get tags =>
      capabilities?.map((c) => c.label).toList() ?? ["Assistant"];
  String get category {
    if (sizeMb < 600) return "Lightweight";
    if (specialty.toLowerCase().contains("code") ||
        specialty.toLowerCase().contains("function")) {
      return "Coding";
    }
    if (specialty.toLowerCase().contains("reasoning") ||
        specialty.toLowerCase().contains("thinking")) {
      return "Advanced";
    }
    return "General";
  }
}

final List<AIModel> models = [
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
    inputModalities: [AIModality.text, AIModality.image, AIModality.audio],
    outputModalities: [AIModality.text],
    capabilities: [
      AICapability.functionCalling,
      AICapability.thinking,
      AICapability.multilingual,
    ],
    image: Assets.png.gemma,
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
    inputModalities: [AIModality.text, AIModality.image, AIModality.audio],
    outputModalities: [AIModality.text],
    capabilities: [
      AICapability.functionCalling,
      AICapability.thinking,
      AICapability.multilingual,
    ],
    image: Assets.png.gemma,
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
    inputModalities: [
      AIModality.text,
      AIModality.image,
      AIModality.video,
      AIModality.audio,
    ],
    outputModalities: [AIModality.text],
    capabilities: [AICapability.multilingual],
    image: Assets.png.gemma,
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
    inputModalities: [
      AIModality.text,
      AIModality.image,
      AIModality.video,
      AIModality.audio,
    ],
    outputModalities: [AIModality.text],
    capabilities: [AICapability.multilingual],
    image: Assets.png.gemma,
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
    inputModalities: [AIModality.text],
    outputModalities: [AIModality.text],
    capabilities: [AICapability.multilingual],
    image: Assets.png.gemma,
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
    inputModalities: [AIModality.text],
    outputModalities: [AIModality.text],
    capabilities: [AICapability.multilingual],
    image: Assets.png.gemma,
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
    inputModalities: [AIModality.text],
    outputModalities: [AIModality.text],
    capabilities: [AICapability.functionCalling],
    image: Assets.png.gemma,
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
    inputModalities: [AIModality.text],
    outputModalities: [AIModality.text],
    capabilities: [
      AICapability.thinking,
      AICapability.multilingual,
      AICapability.functionCalling,
    ],
    image: Assets.png.qwen,
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
    inputModalities: [AIModality.text],
    outputModalities: [AIModality.text],
    capabilities: [AICapability.multilingual, AICapability.code],
    image: Assets.png.qwen,
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
    inputModalities: [AIModality.text],
    outputModalities: [AIModality.text],
    capabilities: [AICapability.multilingual],
    image: Assets.png.qwen,
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
    inputModalities: [AIModality.text],
    outputModalities: [AIModality.text],
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
    inputModalities: [AIModality.text],
    outputModalities: [AIModality.text],
    capabilities: [
      AICapability.thinking,
      AICapability.functionCalling,
      AICapability.multilingual,
      AICapability.code,
    ],
    image: Assets.png.microsoft,
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
    inputModalities: [AIModality.text],
    outputModalities: [AIModality.text],
    capabilities: [AICapability.thinking],
    image: Assets.png.deepseek,
  ),
];
