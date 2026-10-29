import 'dart:convert';

import 'package:http/http.dart' as http;

class TranslationService {
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty || sourceLanguage == targetLanguage) {
      return cleanText;
    }

    final uri = Uri.parse(
      'https://translate.googleapis.com/translate_a/single'
      '?client=gtx'
      '&sl=${Uri.encodeQueryComponent(sourceLanguage)}'
      '&tl=${Uri.encodeQueryComponent(targetLanguage)}'
      '&dt=t'
      '&q=${Uri.encodeQueryComponent(cleanText)}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Không thể kết nối dịch vụ dịch');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List || decoded.isEmpty) {
      throw Exception('Dữ liệu bản dịch không hợp lệ');
    }

    final parts = decoded[0] as List;
    return parts.map((part) => part[0].toString()).join();
  }
}
