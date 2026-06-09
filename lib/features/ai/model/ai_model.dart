class AIModel {
  final String url;
  final String name;
  final String maker;
  final String specialty;
  final String description;
  final double sizeMb;
  final int ramGB;

  final List<String> compactibility;

  final List<String>? capabilities;
  final bool? requiresAuth;

  AIModel({
    required this.url,
    required this.name,
    required this.maker,
    required this.specialty,
    required this.description,
    required this.sizeMb,
    required this.ramGB,

    required this.compactibility,
    this.capabilities,
    this.requiresAuth,
  });

  String get id => url;
  bool get popular => name.contains('Gemma 4') || name.contains('R1');
  double get sizeGB => sizeMb / 1024;
  int get iq => sizeMb > 3000 ? 90 : (sizeMb > 1000 ? 80 : 70);

  String get size =>
      sizeGB < 1
          ? '${(sizeGB * 1000).toStringAsFixed(0)} MB'
          : '${sizeGB.toStringAsFixed(1)} GB';
  List<String> get tags => capabilities ?? ["Assistant"];
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
