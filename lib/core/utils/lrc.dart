class LrcLine {
  LrcLine(this.time, this.text);
  final Duration time;
  final String text;
}

class LrcParser {
  static final _tag = RegExp(r'\[(\d{1,2}):(\d{1,2})(?:[.:](\d{1,3}))?\]');

  static List<LrcLine>? parse(String raw) {
    final out = <LrcLine>[];
    for (final line in raw.split('\n')) {
      final tags = _tag.allMatches(line).toList();
      if (tags.isEmpty) continue;
      final text = line.replaceAll(_tag, '').trim();
      for (final t in tags) {
        final m = int.parse(t.group(1)!), s = int.parse(t.group(2)!);
        final frac = t.group(3);
        final ms = frac == null ? 0 : int.parse(frac.padRight(3, '0'));
        out.add(LrcLine(Duration(minutes: m, seconds: s, milliseconds: ms), text));
      }
    }
    if (out.isEmpty) return null;
    out.sort((a, b) => a.time.compareTo(b.time));
    return out;
  }
}