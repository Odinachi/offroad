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
}
