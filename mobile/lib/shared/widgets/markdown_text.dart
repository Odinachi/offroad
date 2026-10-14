import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Parsing — pure functions, no Flutter dependencies, so they're unit-testable.
// Covers the subset of Markdown that chat models actually produce and is
// tolerant of half-finished input, because it runs on every streamed token.
// ─────────────────────────────────────────────────────────────────────────────

sealed class MdBlock {
  const MdBlock();
}

class MdParagraph extends MdBlock {
  const MdParagraph(this.text);
  final String text;
}

class MdHeading extends MdBlock {
  const MdHeading(this.level, this.text);
  final int level;
  final String text;
}

class MdCode extends MdBlock {
  const MdCode(this.code, {this.language});
  final String code;
  final String? language;
}

class MdListItem extends MdBlock {
  const MdListItem(this.text, {this.number, this.depth = 0});
  final String text;

  /// The written number for ordered items, null for bullets.
  final int? number;
  final int depth;
}

class MdQuote extends MdBlock {
  const MdQuote(this.text);
  final String text;
}

class MdRule extends MdBlock {
  const MdRule();
}

class MdTable extends MdBlock {
  const MdTable(this.rows);

  /// First row is the header.
  final List<List<String>> rows;
}

final _fence = RegExp(r'^\s*```\s*([\w+#.-]*)\s*$');
final _heading = RegExp(r'^(#{1,6})\s+(.*?)(?:\s+#+)?\s*$');
final _rule = RegExp(r'^\s*([-*_])(\s*\1){2,}\s*$');
final _bullet = RegExp(r'^(\s*)[-*+•]\s+(.*)$');
final _ordered = RegExp(r'^(\s*)(\d{1,9})[.)]\s+(.*)$');
final _quote = RegExp(r'^\s*>\s?(.*)$');
final _tableRow = RegExp(r'^\s*\|.*\|\s*$');
final _tableDivider = RegExp(
  r'^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)*\|?\s*$',
);

List<MdBlock> parseMarkdownBlocks(String source) {
  final lines = source.replaceAll('\r\n', '\n').split('\n');
  final blocks = <MdBlock>[];
  final paragraph = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(MdParagraph(paragraph.join('\n')));
    paragraph.clear();
  }

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];

    final fence = _fence.firstMatch(line);
    if (fence != null) {
      flushParagraph();
      final code = <String>[];
      i++;
      // An unclosed fence (mid-stream) runs to the end of the text.
      while (i < lines.length && !_fence.hasMatch(lines[i])) {
        code.add(lines[i]);
        i++;
      }
      final lang = fence.group(1)!;
      blocks.add(MdCode(code.join('\n'), language: lang.isEmpty ? null : lang));
      i++;
      continue;
    }

    if (line.trim().isEmpty) {
      flushParagraph();
      i++;
      continue;
    }

    if (_tableRow.hasMatch(line) &&
        i + 1 < lines.length &&
        _tableDivider.hasMatch(lines[i + 1])) {
      flushParagraph();
      final rows = <List<String>>[_splitRow(line)];
      i += 2;
      while (i < lines.length && _tableRow.hasMatch(lines[i])) {
        rows.add(_splitRow(lines[i]));
        i++;
      }
      blocks.add(MdTable(rows));
      continue;
    }

    final heading = _heading.firstMatch(line);
    if (heading != null) {
      flushParagraph();
      blocks.add(MdHeading(heading.group(1)!.length, heading.group(2)!));
    } else if (_rule.hasMatch(line)) {
      flushParagraph();
      blocks.add(const MdRule());
    } else if (_bullet.firstMatch(line) case final m?) {
      flushParagraph();
      blocks.add(MdListItem(m.group(2)!, depth: _depth(m.group(1)!)));
    } else if (_ordered.firstMatch(line) case final m?) {
      flushParagraph();
      blocks.add(
        MdListItem(
          m.group(3)!,
          number: int.parse(m.group(2)!),
          depth: _depth(m.group(1)!),
        ),
      );
    } else if (_quote.firstMatch(line) case final m?) {
      flushParagraph();
      final quoted = [m.group(1)!];
      while (i + 1 < lines.length && _quote.hasMatch(lines[i + 1])) {
        i++;
        quoted.add(_quote.firstMatch(lines[i])!.group(1)!);
      }
      blocks.add(MdQuote(quoted.join('\n')));
    } else {
      paragraph.add(line);
    }
    i++;
  }
  flushParagraph();
  return blocks;
}

int _depth(String indent) =>
    (indent.replaceAll('\t', '    ').length / 2).floor();

List<String> _splitRow(String line) {
  var row = line.trim();
  if (row.startsWith('|')) row = row.substring(1);
  if (row.endsWith('|')) row = row.substring(0, row.length - 1);
  return row.split('|').map((c) => c.trim()).toList();
}

class MdInline {
  const MdInline(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.code = false,
    this.link,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool code;
  final String? link;
}

final _inline = RegExp(
  r'`([^`\n]+)`'
  r'|\*\*(.+?)\*\*'
  r'|__(.+?)__'
  r'|\[([^\]\n]+)\]\(([^)\s]+)\)'
  r'|(?<![\w*])\*(?![\s*])(.+?)(?<![\s*])\*(?![\w*])'
  r'|(?<!\w)_(?![\s_])(.+?)(?<![\s_])_(?!\w)',
);

List<MdInline> parseMarkdownInline(
  String text, {
  bool bold = false,
  bool italic = false,
}) {
  final out = <MdInline>[];
  var cursor = 0;
  for (final m in _inline.allMatches(text)) {
    if (m.start > cursor) {
      out.add(
        MdInline(text.substring(cursor, m.start), bold: bold, italic: italic),
      );
    }
    if (m.group(1) != null) {
      out.add(MdInline(m.group(1)!, code: true));
    } else if ((m.group(2) ?? m.group(3)) case final inner?) {
      out.addAll(parseMarkdownInline(inner, bold: true, italic: italic));
    } else if (m.group(4) != null) {
      out.add(
        MdInline(m.group(4)!, bold: bold, italic: italic, link: m.group(5)),
      );
    } else if ((m.group(6) ?? m.group(7)) case final inner?) {
      out.addAll(parseMarkdownInline(inner, bold: bold, italic: true));
    }
    cursor = m.end;
  }
  if (cursor < text.length) {
    out.add(MdInline(text.substring(cursor), bold: bold, italic: italic));
  }
  return out;
}

// ─────────────────────────────────────────────────────────────────────────────
// Rendering
// ─────────────────────────────────────────────────────────────────────────────

const _monoFamily = 'Menlo';
const _monoFallback = ['Courier', 'monospace', 'RobotoMono'];

class MarkdownText extends StatefulWidget {
  const MarkdownText({super.key, required this.content, this.color});

  final String content;

  /// Body text color; defaults to `onSurface`.
  final Color? color;

  @override
  State<MarkdownText> createState() => _MarkdownTextState();
}

class _MarkdownTextState extends State<MarkdownText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.onSurface;
    final base = JemenaiTheme.fontBody(
      fontSize: 14,
      color: color,
      lineHeight: 1.45,
    );

    final blocks = parseMarkdownBlocks(widget.content);
    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) children.add(SizedBox(height: _gapBefore(blocks[i])));
      children.add(_buildBlock(blocks[i], base, theme));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  double _gapBefore(MdBlock block) => switch (block) {
    MdListItem() => 4,
    MdHeading() => 12,
    _ => 8,
  };

  Widget _buildBlock(MdBlock block, TextStyle base, ThemeData theme) {
    final jc = theme.jColors;
    switch (block) {
      case MdParagraph(:final text):
        return Text.rich(_spans(text, base, theme));
      case MdHeading(:final level, :final text):
        final size = switch (level) {
          1 => 19.0,
          2 => 17.0,
          3 => 15.5,
          _ => 14.5,
        };
        return Text.rich(
          _spans(
            text,
            JemenaiTheme.fontDisplay(
              fontSize: size,
              fontWeight: FontWeight.w700,
              color: base.color,
            ),
            theme,
          ),
        );
      case MdListItem(:final text, :final number, :final depth):
        return Padding(
          padding: EdgeInsets.only(left: depth * 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: number == null ? 16 : 24,
                child: Text(
                  number == null ? '•' : '$number.',
                  style: base.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(child: Text.rich(_spans(text, base, theme))),
            ],
          ),
        );
      case MdQuote(:final text):
        return Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 3,
              ),
            ),
          ),
          child: Text.rich(
            _spans(text, base.copyWith(color: jc.mutedForeground), theme),
          ),
        );
      case MdRule():
        return Divider(height: 8, color: jc.border);
      case MdCode(:final code, :final language):
        return _CodeBlock(code: code, language: language);
      case MdTable(:final rows):
        return _buildTable(rows, base, theme);
    }
  }

  Widget _buildTable(List<List<String>> rows, TextStyle base, ThemeData theme) {
    final jc = theme.jColors;
    final columns = rows.fold<int>(0, (n, r) => r.length > n ? r.length : n);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(
          color: jc.border,
          borderRadius: BorderRadius.circular(8),
        ),
        children: [
          for (var r = 0; r < rows.length; r++)
            TableRow(
              decoration:
                  r == 0 ? BoxDecoration(color: jc.secondaryFill) : null,
              children: [
                for (var c = 0; c < columns; c++)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text.rich(
                      _spans(
                        c < rows[r].length ? rows[r][c] : '',
                        r == 0
                            ? base.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            )
                            : base.copyWith(fontSize: 13),
                        theme,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  TextSpan _spans(String text, TextStyle style, ThemeData theme) {
    final linkColor =
        theme.brightness == Brightness.dark
            ? const Color(0xFF93C5FD)
            : const Color(0xFF2563EB);
    return TextSpan(
      style: style,
      children: [
        for (final part in parseMarkdownInline(text))
          if (part.code)
            TextSpan(
              text: part.text,
              style: style.copyWith(
                fontFamily: _monoFamily,
                fontFamilyFallback: _monoFallback,
                fontSize: (style.fontSize ?? 14) - 1,
                backgroundColor: theme.jColors.secondaryFill,
              ),
            )
          else
            TextSpan(
              text: part.text,
              style: TextStyle(
                fontWeight: part.bold ? FontWeight.w700 : null,
                fontStyle: part.italic ? FontStyle.italic : null,
                color: part.link != null ? linkColor : null,
                decoration: part.link != null ? TextDecoration.underline : null,
                decorationColor: part.link != null ? linkColor : null,
              ),
              recognizer:
                  part.link == null ? null : _linkRecognizer(part.link!),
            ),
      ],
    );
  }

  TapGestureRecognizer? _linkRecognizer(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    final recognizer =
        TapGestureRecognizer()
          ..onTap =
              () => launchUrlString(url, mode: LaunchMode.externalApplication);
    _recognizers.add(recognizer);
    return recognizer;
  }
}

class _CodeBlock extends StatefulWidget {
  const _CodeBlock({required this.code, this.language});

  final String code;
  final String? language;

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4ADE80);
    const muted = Color(0xFF9CA3AF);
    final accent = _copied ? green : muted;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.language ?? 'code',
                    style: JemenaiTheme.fontBody(
                      fontSize: 11,
                      color: green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _copy,
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: Icon(
                    _copied ? Icons.done_all : Icons.content_copy,
                    size: 13,
                  ),
                  label: Text(
                    _copied ? 'Copied' : 'Copy',
                    style: JemenaiTheme.fontBody(
                      fontSize: 11,
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              widget.code,
              style: const TextStyle(
                fontFamily: _monoFamily,
                fontFamilyFallback: _monoFallback,
                fontSize: 12,
                height: 1.5,
                color: Color(0xFFE6EDF3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
