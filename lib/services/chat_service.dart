class ChatService {
  Future<String> sendMessage(String message) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return "This is a mock response to: $message";
  }
}
