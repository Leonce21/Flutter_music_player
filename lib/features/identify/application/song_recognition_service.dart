import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SongRecognitionResult {
  final String title;
  final String artist;
  final String? album;
  final String? artworkUrl;

  SongRecognitionResult({
    required this.title,
    required this.artist,
    this.album,
    this.artworkUrl,
  });
}

abstract class SongRecognitionService {
  Future<SongRecognitionResult?> identify(File audioFile);
}

class AudDSongRecognitionService implements SongRecognitionService {
  final String _apiToken;

  AudDSongRecognitionService({
    String? apiToken,
  }) : _apiToken = apiToken ?? const String.fromEnvironment('AUDD_API_TOKEN', defaultValue: '3a96ae8b64190bbb26d0772662a05edf');

  @override
  Future<SongRecognitionResult?> identify(File audioFile) async {
    final uri = Uri.parse('https://api.audd.io/');
    final request = http.MultipartRequest('POST', uri)
      ..fields['api_token'] = _apiToken
      ..fields['return'] = 'apple_music,spotify'
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['result'] != null) {
          final result = data['result'];
          
          String title = result['title'] ?? 'Unknown Title';
          String artist = result['artist'] ?? 'Unknown Artist';
          String? album;
          String? artworkUrl;

          // Extract rich metadata from Apple Music if available
          if (result['apple_music'] != null) {
            album = result['apple_music']['albumName'];
            artworkUrl = result['apple_music']['artworkUrl100'];
            if (artworkUrl != null) {
              // Upgrade artwork to high resolution
              artworkUrl = artworkUrl.replaceFirst('100x100bb', '600x600bb');
            }
          }

          return SongRecognitionResult(
            title: title,
            artist: artist,
            album: album,
            artworkUrl: artworkUrl,
          );
        }
      }
    } catch (e) {
      rethrow; // Let the Notifier handle network/timeout errors
    }
    return null; // No match found
  }
}