import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prefs.dart';

class _IntListNotifier extends Notifier<List<int>> {
  _IntListNotifier(this._key);
  final String _key;

  List<int> _read() {
    switch (_key) {
      case 'favs': return Prefs.favorites;
      case 'recents': return Prefs.recents;
      default: return Prefs.blacklist;
    }
  }

  void _write(List<int> v) {
    switch (_key) {
      case 'favs': Prefs.favorites = v; break;
      case 'recents': Prefs.recents = v; break;
      default: Prefs.blacklist = v;
    }
  }

  @override
  List<int> build() => _read();

  void toggle(int id) {
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
    } else {
      state = [...state, id];
    }
    _write(state);
  }

  void log(int id) {
    state = [id, ...state.where((e) => e != id)].take(50).toList();
    _write(state);
  }

  void add(int id) {
    if (!state.contains(id)) state = [...state, id];
    _write(state);
  }

  void clear() { state = []; _write(state); }
}

final favoritesProvider = NotifierProvider<_IntListNotifier, List<int>>(() => _IntListNotifier('favs'));
final recentsProvider = NotifierProvider<_IntListNotifier, List<int>>(() => _IntListNotifier('recents'));
final blacklistProvider = NotifierProvider<_IntListNotifier, List<int>>(() => _IntListNotifier('blacklist'));

class PlaylistsNotifier extends Notifier<Map<String, List<int>>> {
  @override
  Map<String, List<int>> build() => Prefs.playlistsRaw.map(
      (k, v) => MapEntry(k.toString(), (v as List).cast<int>()));
  
  void _save() => Prefs.playlistsRaw = state.map((k, v) => MapEntry(k, v));
  
  void create(String name) { 
    if (state.containsKey(name)) return;
    state = {...state, name: []}; 
    _save(); 
  }
  
  void delete(String name) { 
    final newState = {...state}..remove(name); 
    state = newState; 
    _save(); 
  }
  
  void addTo(String name, int songId) {
    if (!state.containsKey(name)) return;
    final current = state[name] ?? [];
    if (current.contains(songId)) return;
    final newList = [...current, songId];
    state = {...state, name: newList}; 
    _save();
  }
  
  void removeFrom(String name, int songId) {
    if (!state.containsKey(name)) return;
    final newList = (state[name] ?? []).where((id) => id != songId).toList();
    state = {...state, name: newList}; 
    _save();
  }

  void rename(String oldName, String newName) {
    if (oldName == newName || state.containsKey(newName)) return;
    final songs = state[oldName] ?? [];
    final newState = {...state}..remove(oldName);
    newState[newName] = songs;
    state = newState;
    _save();
  }
}

final playlistsProvider = NotifierProvider<PlaylistsNotifier, Map<String, List<int>>>(PlaylistsNotifier.new);

class HistoryNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => Prefs.history;
  void log(String q) {
    if (q.trim().isEmpty) return;
    state = [q, ...state.where((e) => e != q)].take(10).toList();
    Prefs.history = state;
  }
  void remove(String q) {
    state = [...state..remove(q)];
    Prefs.history = state;
  }
  void clear() { state = []; Prefs.history = state; }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<String>>(HistoryNotifier.new);
final sortPrefProvider = StateProvider.family<String, String>((ref, tab) => Prefs.sortFor(tab));