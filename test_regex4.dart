void main() {
  final content = "Here is code:\n```dart\nprint('hello');";
  final regex = RegExp(r'(```[\s\S]*?(?:```|$)|\*\*[\s\S]*?(?:\*\*|$)|\*[^*]+(?:\*|$)|---[\s\S]*?(?:---|$))');
  final matches = regex.allMatches(content);
  int currentIndex = 0;
  final parts = <String>[];
  for (final match in matches) {
    if (match.start > currentIndex) {
      parts.add(content.substring(currentIndex, match.start));
    }
    parts.add(match.group(0)!);
    currentIndex = match.end;
  }
  if (currentIndex < content.length) {
    parts.add(content.substring(currentIndex));
  }
  
  for (var i = 0; i < parts.length; i++) {
    print("Part $i: ${parts[i]}");
  }
}
