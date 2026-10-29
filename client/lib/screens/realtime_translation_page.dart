import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../models/translation_result.dart';
import '../services/translation_service.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_result_card.dart';

class RealtimeTranslationPage extends StatefulWidget {
  const RealtimeTranslationPage({super.key});

  @override
  State<RealtimeTranslationPage> createState() =>
      _RealtimeTranslationPageState();
}

class _RealtimeTranslationPageState extends State<RealtimeTranslationPage>
    with WidgetsBindingObserver {
  final ImagePicker picker = ImagePicker();
  final TextRecognizer recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  final TranslationService translationService = TranslationService();

  CameraController? cameraController;
  Timer? scanTimer;
  bool cameraReady = false;
  bool liveTranslating = false;
  bool processingFrame = false;
  bool loadingPhoto = false;

  String sourceLanguage = 'vi';
  String targetLanguage = 'en';
  File? selectedImage;
  String extractedText = '';
  final List<TranslationResult> results = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        showMessage('Không tìm thấy camera', error: true);
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      cameraController = controller;
      setState(() => cameraReady = true);
    } catch (error) {
      showMessage('Không thể mở camera: $error', error: true);
    }
  }

  void startLiveTranslation() {
    if (!cameraReady || liveTranslating) return;

    setState(() => liveTranslating = true);
    scanTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => scanCurrentFrame(),
    );

    scanCurrentFrame();
  }

  Future<void> stopLiveTranslation() async {
    scanTimer?.cancel();
    scanTimer = null;
    if (mounted) setState(() => liveTranslating = false);
  }

  Future<void> scanCurrentFrame() async {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (processingFrame || !liveTranslating) return;

    processingFrame = true;
    try {
      final file = await controller.takePicture();
      await recognizeAndTranslate(File(file.path), addToHistory: false);
    } catch (error) {
      if (mounted) showMessage('Không đọc được khung hình: $error', error: true);
    } finally {
      processingFrame = false;
    }
  }

  Future<void> selectPhoto() async {
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (photo == null) return;

    setState(() {
      selectedImage = File(photo.path);
    });
    await recognizeAndTranslate(File(photo.path), addToHistory: true);
  }

  Future<void> takePhotoForTranslation() async {
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (photo == null) return;

    setState(() {
      selectedImage = File(photo.path);
    });
    await recognizeAndTranslate(File(photo.path), addToHistory: true);
  }

  Future<void> recognizeAndTranslate(
    File image, {
    required bool addToHistory,
  }) async {
    if (loadingPhoto && addToHistory) return;
    if (addToHistory && mounted) setState(() => loadingPhoto = true);

    try {
      final recognized = await recognizer.processImage(
        InputImage.fromFile(image),
      );
      final text = recognized.text.trim();

      if (text.isEmpty) return;

      final translated = await translationService.translate(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      if (!mounted) return;
      setState(() {
        extractedText = text;
        if (addToHistory || results.isEmpty || results.last.originalText != text) {
          results.add(TranslationResult(
            originalText: text,
            translatedText: translated,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            createdAt: DateTime.now(),
          ));
          if (results.length > 30) results.removeAt(0);
        }
      });
    } catch (error) {
      if (addToHistory && mounted) {
        showMessage(error.toString().replaceFirst('Exception: ', ''), error: true);
      }
    } finally {
      if (addToHistory && mounted) setState(() => loadingPhoto = false);
    }
  }

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red.shade700 : const Color(0xFF0B6E69),
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      stopLiveTranslation();
      cameraController?.dispose();
      cameraController = null;
      if (mounted) setState(() => cameraReady = false);
    } else if (state == AppLifecycleState.resumed) {
      initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scanTimer?.cancel();
    cameraController?.dispose();
    recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latest = results.isEmpty ? null : results.last;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dịch realtime bằng camera'),
        actions: [
          IconButton(
            onPressed: () => setState(() => results.clear()),
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9F6F1), Color(0xFFF9F4E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              LanguageSelector(
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                onSourceChanged: (value) => setState(() => sourceLanguage = value),
                onTargetChanged: (value) => setState(() => targetLanguage = value),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 300,
                  child: cameraReady && cameraController != null
                      ? CameraPreview(cameraController!)
                      : const ColoredBox(
                          color: Colors.black12,
                          child: Center(child: Text('Đang khởi động camera...')),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: cameraReady
                          ? (liveTranslating ? stopLiveTranslation : startLiveTranslation)
                          : null,
                      icon: Icon(liveTranslating ? Icons.stop : Icons.camera_rounded),
                      label: Text(liveTranslating ? 'Dừng dịch trực tiếp' : 'Dịch trực tiếp'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Chụp ảnh để dịch',
                    onPressed: loadingPhoto ? null : takePhotoForTranslation,
                    icon: const Icon(Icons.camera_alt_rounded),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Chọn ảnh từ thư viện',
                    onPressed: loadingPhoto ? null : selectPhoto,
                    icon: const Icon(Icons.photo_library_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                liveTranslating
                    ? 'Camera đang quét văn bản mỗi 2 giây...'
                    : 'Bạn vẫn có thể chụp ảnh hoặc chọn ảnh để dịch thủ công.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              if (loadingPhoto) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              if (latest != null) ...[
                const SizedBox(height: 18),
                TranslationResultCard(result: latest),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
