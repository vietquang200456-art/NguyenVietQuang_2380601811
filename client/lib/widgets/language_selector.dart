import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onTargetChanged;

  const LanguageSelector({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  static const sourceLanguages = {
    'vi': 'Tiếng Việt',
    'en': 'English',
    'ko': '한국어',
    'ja': '日本語',
    'zh-CN': '中文',
    'fr': 'Français',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: sourceLanguage,
                decoration: const InputDecoration(
                  labelText: 'Ngôn ngữ gốc',
                  prefixIcon: Icon(Icons.image_search_rounded),
                ),
                items: sourceLanguages.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onSourceChanged(value);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward_rounded),
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: targetLanguage,
                decoration: const InputDecoration(
                  labelText: 'Dịch sang',
                  prefixIcon: Icon(Icons.translate_rounded),
                ),
                items: sourceLanguages.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onTargetChanged(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
