import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  /// Sends a message to Groq API and returns the parsed JSON map
  /// with option_1_kibar, option_2_net, option_3_yaratici keys.
  Future<Map<String, dynamic>> generateResponse(String mode, String userMessage) async {
    final String systemPrompt = "Sen 'Ne Cevap Vereyim?' uygulamasının $mode yapay zeka asistanısın. "
        "Görevin, kullanıcının sana gönderdiği mesajlara verilebilecek en iyi 3 alternatif Türkçe cevabı üretmektir. "
        "Çıktıyı kesinlikle aşağıdaki JSON formatında ver, başka hiçbir şey ekleme:\n"
        '{"option_1_kibar": "Politik ve profesyonel/kibar cevap metni...", '
        '"option_2_net": "Kısa, net ve doğrudan cevap metni...", '
        '"option_3_yaratici": "Esprili, yaratıcı veya duruma göre zekice cevap metni..."}';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'] as String;
        return jsonDecode(text);
      } else if (response.statusCode == 429) {
        // Rate limit — wait and retry
        await Future.delayed(const Duration(seconds: 15));
        return generateResponse(mode, userMessage);
      } else {
        throw Exception('Groq API Hatası [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('API yanıtı JSON formatında değil. Lütfen tekrar deneyin.');
      }
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
