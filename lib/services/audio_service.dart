import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

/// Audio recording and playback management
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Start recording audio
  Future<void> startRecording() async {
    if (_isRecording) return;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentRecordingPath = '${tempDir.path}/recording_$timestamp.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentRecordingPath!,
    );

    _isRecording = true;
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    final path = await _recorder.stop();
    _isRecording = false;
    return path ?? _currentRecordingPath;
  }

  /// Play an audio file
  Future<void> playAudio(String filePath) async {
    if (_isPlaying) {
      await stopPlaying();
    }

    _isPlaying = true;
    
    if (filePath.startsWith('http')) {
      await _player.play(UrlSource(filePath));
    } else {
      await _player.play(DeviceFileSource(filePath));
    }

    // Listen for completion
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });
  }

  /// Stop playing audio
  Future<void> stopPlaying() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Clean up resources
  Future<void> dispose() async {
    if (_isRecording) await stopRecording();
    if (_isPlaying) await stopPlaying();
    _recorder.dispose();
    _player.dispose();
  }

  /// Delete a temporary audio file
  static Future<void> cleanupFile(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
