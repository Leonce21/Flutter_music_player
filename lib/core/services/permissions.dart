// lib/core/services/permissions.dart
import 'package:on_audio_query/on_audio_query.dart';

class PermissionsService {
  PermissionsService._();

  /// Returns true if the app can read audio files on this device.
  static Future<bool> ensureAudioPermission() async {
    final _audioQuery = OnAudioQuery();

    // Check current permission status
    bool hasPermission = await _audioQuery.permissionsStatus();
    if (hasPermission) return true;

    // Request permission (this may show the system dialog)
    hasPermission = await _audioQuery.permissionsRequest();
    if (hasPermission) return true;

    // Fallback: attempt to query songs to test actual access.
    // This works around plugin limitations on Android 13+.
    try {
      final songs = await _audioQuery.querySongs();
      return songs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openSettings() async {
    // Not used; kept for compatibility.
  }
}