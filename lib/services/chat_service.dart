import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl =
      "http://192.168.118.24:8000/ask";

  Future<String> sendMessage({
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "question": message,
        "include_context": false,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"] == true && data["answer"] != null) {
        return data["answer"];
      } else {
        throw Exception("Backend returned unsuccessful response");
      }
    } else {
      throw Exception("Server error ${response.statusCode}");
    }
  }
}

final chatService = ChatService();