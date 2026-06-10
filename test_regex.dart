void main() {
  final content = "Here is code:\n```dart\nprint('hello');";
  final parts = content.split(
      RegExp(r'(```[\s\S]*?(?:```|$)|\*\*[\s\S]*?(?:\*\*|$)|\*[^*]+(?:\*|$)|---[\s\S]*?(?:---|$))'),
    );
  for (var i = 0; i < parts.length; i++) {
    print("Part $i: ${parts[i]}");
  }
}
