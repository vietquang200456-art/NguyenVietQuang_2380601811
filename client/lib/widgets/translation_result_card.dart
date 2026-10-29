import 'package:flutter/material.dart';

import '../models/translation_result.dart';

class TranslationResultCard extends StatelessWidget {
  final TranslationResult result;

  const TranslationResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.text_snippet_outlined, color: Color(0xFF0B6E69)),
                SizedBox(width: 8),
                Text(
                  'Văn bản trong ảnh',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.originalText),
            const Divider(height: 24),
            const Row(
              children: [
                Icon(Icons.translate_rounded, color: Color(0xFF0B6E69)),
                SizedBox(width: 8),
                Text(
                  'Bản dịch',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              result.translatedText,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF0B6E69),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
