import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_recorder_service.dart';
import 'song_recognition_service.dart';

enum IdentifyStatus { idle, listening, processing, success, error, notFound }

class IdentifyState {
  final IdentifyStatus status;
  final SongRecognitionResult? result;
  final String? errorMessage;
  final int elapsedSeconds; // Tracks how long we've been listening

  const IdentifyState({
    this.status = IdentifyStatus.idle,
    this.result,
    this.errorMessage,
    this.elapsedSeconds = 0,
  });

  IdentifyState copyWith({
    IdentifyStatus? status,
    SongRecognitionResult? result,
    String? errorMessage,
    int? elapsedSeconds,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return IdentifyState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class IdentifyNotifier extends Notifier<IdentifyState> {
  late final AudioRecorderService _recorderService;
  late final SongRecognitionService _recognitionService;
  bool _isListening = false;

  @override
  IdentifyState build() {
    _recorderService = AudioRecorderService();
    _recognitionService = AudDSongRecognitionService();
    return const IdentifyState();
  }

  /// Starts the continuous listening loop.
  /// Records in ~5s chunks, checks for a match, and exits early if found.
  Future<void> startListening() async {
    state = state.copyWith(
      status: IdentifyStatus.listening,
      clearError: true,
      clearResult: true,
      elapsedSeconds: 0,
    );

    final hasPermission = await _recorderService.checkPermission();
    if (!hasPermission) {
      state = state.copyWith(
        status: IdentifyStatus.error,
        errorMessage: 'Microphone permission denied.',
      );
      return;
    }

    _isListening = true;
    final stopwatch = Stopwatch()..start();

    // Continuous listening loop with a 2-minute (120s) hard limit
    while (_isListening && stopwatch.elapsed.inSeconds < 120) {
      // Update UI with elapsed time
      state = state.copyWith(elapsedSeconds: stopwatch.elapsed.inSeconds);

      final path = await _recorderService.startRecording();
      if (path == null || !_isListening) break;

      // Record for ~5 seconds, checking every 100ms if the user tapped stop
      for (int i = 0; i < 50; i++) {
        if (!_isListening) break;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // If user manually stopped listening, break the loop
      if (!_isListening) {
        await _recorderService.stopRecording();
        break;
      }

      final recordedPath = await _recorderService.stopRecording();
      if (recordedPath == null) continue;

      final file = File(recordedPath);
      if (!file.existsSync()) continue;

      try {
        // Send the 5s chunk to the API
        final result = await _recognitionService.identify(file);
        
        // 🎯 EARLY EXIT: If a song is found, immediately show success and stop
        if (result != null) {
          state = state.copyWith(
            status: IdentifyStatus.success,
            result: result,
          );
          _isListening = false;
          _cleanup(file);
          return;
        }
      } catch (e) {
        // Ignore transient network/timeout errors and keep trying the next chunk
      }

      _cleanup(file);
    }

    // If we exit the loop (either 2 mins reached or user stopped) without a match
    if (state.status == IdentifyStatus.listening) {
      state = state.copyWith(status: IdentifyStatus.notFound);
    }
    _isListening = false;
  }

  /// Called when the user manually taps the mic to stop listening
  void stopListening() {
    _isListening = false;
    _recorderService.stopRecording();
    state = const IdentifyState(); // Return to idle state
  }

  void reset() {
    _isListening = false;
    state = const IdentifyState();
  }

  void _cleanup(File file) {
    try {
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }
}

final identifyProvider = NotifierProvider<IdentifyNotifier, IdentifyState>(IdentifyNotifier.new);