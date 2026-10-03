import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_stage.dart';

class ChatService {
  final String baseUrl = "https://ai-engine-for-navajeev.onrender.com/ask";

  Future<String> sendMessage({
    required String message,
    ChatContext? context,
  }) async {
    final Map<String, dynamic> body = {
      'question': message,
      'include_context': false,
    };

    if (context != null) {
      final prefix = context.toPromptPrefix();
      if (prefix.isNotEmpty) {
        body['user_context'] = prefix;
      }
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 90));

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
