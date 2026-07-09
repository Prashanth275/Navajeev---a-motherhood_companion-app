import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_stage.dart';

class ChatService {
  final String baseUrl = "http://10.41.84.24:8000/ask";

  Future<String> sendMessage({
    required String message,
    required ChatContext context,
  }) async {
    final contextPrefix = context.toPromptPrefix();
    final enrichedQuestion = '$contextPrefix\n\nQuestion: $message';

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': enrichedQuestion,
        'include_context': false,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['answer'] != null) {
        return data['answer'];
      } else {
        throw Exception('Backend returned unsuccessful response');
      }
    } else {
      throw Exception('Server error ${response.statusCode}');
    }
  }
}

final chatService = ChatService();
