import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jemenai/shared/theme.dart';
import 'package:jemenai/shared/widgets/markdown_text.dart';

void main() {
  group('parseMarkdownInline', () {
    test('keeps bold inline with surrounding text', () {
      final parts = parseMarkdownInline('Hello **world** foo');
      expect(parts.map((p) => p.text), ['Hello ', 'world', ' foo']);
      expect(parts.map((p) => p.bold), [false, true, false]);
    });

    test('parses italic, inline code and links', () {
      final parts = parseMarkdownInline(
        'Use *care* with `rm -rf` — see [docs](https://example.com).',
      );
      expect(parts.firstWhere((p) => p.text == 'care').italic, isTrue);
      expect(parts.firstWhere((p) => p.text == 'rm -rf').code, isTrue);
      final link = parts.firstWhere((p) => p.link != null);
      expect(link.text, 'docs');
      expect(link.link, 'https://example.com');
    });

    test('nests italic inside bold', () {
      final parts = parseMarkdownInline('**very *important* note**');
      final important = parts.firstWhere((p) => p.text == 'important');
      expect(important.bold, isTrue);
      expect(important.italic, isTrue);
    });

    test('leaves snake_case and arithmetic alone', () {
      expect(parseMarkdownInline('my_var_name').single.italic, isFalse);
      expect(parseMarkdownInline('2*3*4 = 24').single.italic, isFalse);
    });

    test('leaves an unfinished bold marker as plain text while streaming', () {
      final parts = parseMarkdownInline('This is **impor');
      expect(parts.every((p) => !p.bold), isTrue);
      expect(parts.map((p) => p.text).join(), 'This is **impor');
    });
  });

  group('parseMarkdownBlocks', () {
    test('headings, paragraphs and lists', () {
      final blocks = parseMarkdownBlocks(
        '# Title\n\nIntro line\nsecond line\n\n- one\n  - nested\n1. first\n2) second',
      );
      expect(blocks[0], isA<MdHeading>());
      expect((blocks[0] as MdHeading).level, 1);
      expect((blocks[1] as MdParagraph).text, 'Intro line\nsecond line');
      final items = blocks.whereType<MdListItem>().toList();
      expect(items.map((i) => i.text), ['one', 'nested', 'first', 'second']);
      expect(items[1].depth, 1);
      expect(items[2].number, 1);
      expect(items[3].number, 2);
    });

    test('heading keeps a trailing # that belongs to the text', () {
      final heading = parseMarkdownBlocks('## Learning C#').single as MdHeading;
      expect(heading.text, 'Learning C#');
    });

    test('code fences, including an unclosed one mid-stream', () {
      final closed = parseMarkdownBlocks('```dart\nvoid main() {}\n```\nAfter');
      expect((closed[0] as MdCode).language, 'dart');
      expect((closed[0] as MdCode).code, 'void main() {}');
      expect((closed[1] as MdParagraph).text, 'After');

      final open = parseMarkdownBlocks('Here:\n```py\nprint(1)\nprint(2');
      final code = open.whereType<MdCode>().single;
      expect(code.code, 'print(1)\nprint(2');
    });

    test('a horizontal rule does not swallow the text after it', () {
      final blocks = parseMarkdownBlocks('Before\n\n---\n\nAfter');
      expect(blocks, hasLength(3));
      expect(blocks[1], isA<MdRule>());
      expect((blocks[2] as MdParagraph).text, 'After');
    });

    test('block quotes merge consecutive lines', () {
      final quote = parseMarkdownBlocks('> line one\n> line two').single;
      expect((quote as MdQuote).text, 'line one\nline two');
    });

    test('tables become rows of cells', () {
      final table =
          parseMarkdownBlocks(
                '| Model | Size |\n|---|---:|\n| Gemma | 2.6 GB |\n| Qwen | 0.6 GB |',
              ).single
              as MdTable;
      expect(table.rows, [
        ['Model', 'Size'],
        ['Gemma', '2.6 GB'],
        ['Qwen', '0.6 GB'],
      ]);
    });
  });

  testWidgets('MarkdownText renders inline bold inside a single paragraph', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: JemenaiTheme.lightTheme(),
        home: const Scaffold(
          body: MarkdownText(content: 'Hello **world** foo'),
        ),
      ),
    );
    // One RichText holding the whole sentence — the old renderer stacked
    // "Hello", "world" and "foo" on three separate lines.
    expect(find.text('Hello world foo', findRichText: true), findsOneWidget);
  });

  testWidgets('MarkdownText shows a copy button for code blocks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: JemenaiTheme.darkTheme(),
        home: const Scaffold(
          body: MarkdownText(content: '```bash\necho hi\n```'),
        ),
      ),
    );
    expect(find.text('bash'), findsOneWidget);
    expect(find.text('echo hi'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
