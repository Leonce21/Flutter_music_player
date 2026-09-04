import 'package:on_audio_query/on_audio_query.dart';

const sortKeys = [
  'Ascending', 'Descending', 'Artist', 'Album',
  'Year', 'Date Added', 'Date Modified', 'Composer',
];

int _cmp(String? a, String? b) =>
    (a ?? '').toLowerCase().compareTo((b ?? '').toLowerCase());

int _year(SongModel s) => (s.getMap['year'] as int?) ?? 0;

int compareSongs(SongModel a, SongModel b, String key) {
  switch (key) {
    case 'Descending': return _cmp(b.title, a.title);
    case 'Artist': return _cmp(a.artist, b.artist);
    case 'Album': return _cmp(a.album, b.album);
    case 'Year': return _year(a).compareTo(_year(b));
    case 'Date Added': return (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0);
    case 'Date Modified':
      return (a.dateModified ?? 0).compareTo(b.dateModified ?? 0);
    case 'Composer': return _cmp(a.composer, b.composer);
    default: return _cmp(a.title, b.title);
  }
}