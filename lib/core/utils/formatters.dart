String fmtDur(Duration? d) {
  if (d == null || d.isNegative || d == Duration.zero) return '00:00';
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  final mm = m.toString().padLeft(2, '0'), ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

String fmtLong(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

String fmtMs(int? ms) =>
    fmtDur(ms == null ? null : Duration(milliseconds: ms));

String fmtBytes(int b) {
  const mb = 1024 * 1024;
  return '${(b / mb).toStringAsFixed(1)} MB';
}