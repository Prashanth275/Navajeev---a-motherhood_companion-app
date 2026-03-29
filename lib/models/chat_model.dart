enum ChatSender { user, bot }

class ChatMessage {
  final ChatSender sender;
  final String text;

  const ChatMessage({
    required this.sender,
    required this.text,
  });

  ChatMessage copyWith({String? text}) {
    return ChatMessage(
      sender: sender,
      text: text ?? this.text,
    );
  }
}

