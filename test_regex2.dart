void main() {
  final content = "Here is code:\n```dart\nprint('hello');";
  final regex = RegExp(r'(```[\s\S]*?(?:```|$)|\*\*[\s\S]*?(?:\*\*|$)|\*[^*]+(?:\*|$)|---[\s\S]*?(?:---|$))');
  final matches = regex.allMatches(content);
  for (var m in matches) {
    print("Match: ${m.group(0)}");
  }
}
