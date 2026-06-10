void main() {
  final content = "Here is code:\n```dart\nprint('hello');";
  final regex = RegExp(r'(```[\s\S]*?(?:```|$)|\*\*[\s\S]*?(?:\*\*|$)|\*[^*]+(?:\*|$)|---[\s\S]*?(?:---|$))');
  final parts = content.split(regex);
  for (var i = 0; i < parts.length; i++) {
    print("Part $i: ${parts[i]}");
  }
}
