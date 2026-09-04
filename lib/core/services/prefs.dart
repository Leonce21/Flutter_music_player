import 'package:hive_flutter/hive_flutter.dart';

class Prefs {
  Prefs._();
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('mume');
  }

  static bool get onboarded => _box.get('onboarded', defaultValue: false);
  static set onboarded(bool v) => _box.put('onboarded', v);

  static String sortFor(String tab) =>
      _box.get('sort_$tab', defaultValue: 'Ascending');
  static void setSort(String tab, String v) => _box.put('sort_$tab', v);

  static List<int> _list(String k) =>
      (_box.get(k, defaultValue: <int>[])).cast<int>();
  static void _putList(String k, List<int> v) => _box.put(k, v);

  static List<int> get favorites => _list('favs');
  static set favorites(List<int> v) => _putList('favs', v);
  static List<int> get recents => _list('recents');
  static set recents(List<int> v) => _putList('recents', v);
  static List<int> get blacklist => _list('blacklist');
  static set blacklist(List<int> v) => _putList('blacklist', v);

  static List<String> get history =>
      (_box.get('history', defaultValue: <String>[])).cast<String>();
  static set history(List<String> v) => _box.put('history', v);

  static Map<dynamic, dynamic> get playlistsRaw =>
      _box.get('playlists', defaultValue: <dynamic, dynamic>{});
  static set playlistsRaw(Map<dynamic, dynamic> v) => _box.put('playlists', v);

  static int playCount(int id) =>
      ((_box.get('counts', defaultValue: <dynamic, dynamic>{}))[id] as int?) ?? 0;
      
  static void bumpCount(int id) {
    final m = Map<dynamic, dynamic>.from(
        _box.get('counts', defaultValue: <dynamic, dynamic>{}));
    m[id] = (m[id] as int? ?? 0) + 1;
    _box.put('counts', m);
  }

  static List<int> recentsOrder() => recents;
}