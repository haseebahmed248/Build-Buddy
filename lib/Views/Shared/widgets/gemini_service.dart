// lib/Services/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();

  factory GeminiService() => _instance;

  GeminiService._internal();

  final String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String?> generateResponse(String prompt) async {
    try {
      final url =
          Uri.parse('$baseUrl?key=AIzaSyDEZFlEGriVLNMAnKDCUAhDcwYMUJ5H-xE');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      return null;
    } catch (e) {
      print('Error generating response: $e');
      return null;
    }
  }
}
