import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

import '../models/translation_result.dart';
import 'translation_service.dart';

class SpeechTranslationService {
  final SpeechToText speechToText = SpeechToText();
  final TranslationService translationService = TranslationService();

  bool initialized = false;
  bool listening = false;

  Timer? translationTimer;
  String lastText = '';

  Future<bool> initialize() async {
    initialized = await speechToText.initialize(
      onError: (error) {
        listening = false;
      },
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          listening = false;
        }
      },
    );
    return initialized;
  }

  Future<void> start({
    required String sourceLanguage,
    required String targetLanguage,
    required void Function(TranslationResult result) onResult,
    required void Function(String error) onError,
  }) async {
    if (!initialized) {
      final initializedSuccessfully = await initialize();

      if (!initializedSuccessfully) {
        onError('Thiết bị không hỗ trợ nhận diện giọng nói');
        return;
      }
    }

    if (listening) {
      return;
    }

    listening = true;
    lastText = '';

    await speechToText.listen(
      localeId: sourceLanguage.contains('-') ? sourceLanguage : '_VN',
      listenMode: ListenMode.dictation,
      partialResults: true,
      onResult: (speechResult) {
        final recognizedText =
            speechResult.recognizedWords.trim();

        if (recognizedText.isEmpty) {
          return;
        }

        if (recognizedText == lastText) {
          return;
        }

        lastText = recognizedText;

        translationTimer?.cancel();

        translationTimer = Timer(
          const Duration(milliseconds: 500),
          () async {
            try {
              final translatedText =
                  await translationService.translate(
                text: recognizedText,
                sourceLanguage:
                    sourceLanguage.split('-').first,
                targetLanguage: targetLanguage,
              );

              onResult(
                TranslationResult(
                  originalText: recognizedText,
                  translatedText: translatedText,
                  sourceLanguage: sourceLanguage,
                  targetLanguage: targetLanguage,
                  createdAt: DateTime.now(),
                ),
              );
            } catch (error) {
              onError(error.toString());
            }
          },
        );
      },
    );
  }

  Future<void> stop() async {
    translationTimer?.cancel();
    await speechToText.stop();
    listening = false;
  }

  Future<void> cancel() async {
    translationTimer?.cancel();
    await speechToText.cancel();
    listening = false;
  }

  Future<void> dispose() async {
    translationTimer?.cancel();
    await speechToText.cancel();
    listening = false;
  }
}