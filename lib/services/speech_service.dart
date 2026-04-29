import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';

/// Speech-to-Text service using OpenAI Whisper API
class SpeechToTextService {
  /// Transcribe an audio file to text using Whisper
  static Future<String> transcribe(String audioFilePath) async {
    try {
      final file = File(audioFilePath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $audioFilePath');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.audioBaseUrl}/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer ${ApiConfig.audioApiKey}';
      request.fields['model'] = ApiConfig.whisperModel;
      request.fields['language'] = 'en'; // Optimize for English
      request.fields['response_format'] = 'text';

      request.files.add(
        await http.MultipartFile.fromPath('file', audioFilePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body.trim();
      } else {
        throw Exception(
            'Whisper API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Speech-to-text failed: $e');
    }
  }
}

/// Text-to-Speech service using OpenAI TTS API
class TextToSpeechService {
  /// Convert text to speech audio file
  /// Returns the path to the generated audio file
  static Future<String> synthesize(String text,
      {String voice = 'alloy'}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.audioBaseUrl}/audio/speech'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.audioApiKey}',
        },
        body: jsonEncode({
          'model': ApiConfig.ttsModel,
          'input': text,
          'voice': voice,
          'response_format': 'mp3',
          'speed': 1.0,
        }),
      );

      if (response.statusCode == 200) {
        // Save audio to temp file
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final audioFile = File('${tempDir.path}/tts_$timestamp.mp3');
        await audioFile.writeAsBytes(response.bodyBytes);
        return audioFile.path;
      } else if (response.statusCode == 429) {
        // Rate limit or quota exceeded — try to parse the error body for details
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>?;
          final err =
              body != null && body.containsKey('error') ? body['error'] : null;
          final errMsg = err != null && err['message'] != null
              ? err['message']
              : response.body;
          final errCode =
              err != null && err['code'] != null ? err['code'] : null;

          if (errCode == 'insufficient_quota' ||
              (err != null && err['type'] == 'insufficient_quota')) {
            throw Exception(
                'TTS failed: insufficient quota. Check your OpenAI plan and billing: https://platform.openai.com/account/usage. Message: $errMsg');
          }

          final retryAfter = response.headers['retry-after'];
          if (retryAfter != null) {
            throw Exception(
                'TTS rate limited. Retry after $retryAfter seconds. Message: $errMsg');
          }

          throw Exception('TTS rate limited (429): $errMsg');
        } catch (parseError) {
          throw Exception('TTS API error: 429 - ${response.body}');
        }
      } else {
        throw Exception(
            'TTS API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception(
          'Text-to-speech failed: $e\nHint: If you see an "insufficient_quota" error, check OpenAI billing/usage.\nConsider adding a local device fallback (for example `flutter_tts`) to improve reliability when remote TTS is unavailable.');
    }
  }
}
