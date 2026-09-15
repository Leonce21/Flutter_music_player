import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  Future<String?> startRecording() async {
    if (await _recorder.hasPermission()) {
      // Using system temp directory avoids needing path_provider or external storage permissions
      final path = '${Directory.systemTemp.path}/identify_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      return path;
    }
    return null;
  }

  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  void dispose() {
    _recorder.dispose();
  }
}