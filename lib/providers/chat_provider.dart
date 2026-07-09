import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/chat_stage.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  ChatContext? _context;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  ChatContext? get context => _context;

  void initialize(ChatContext context) {
    _context = context;

    if (_messages.isEmpty) {
      final greeting = context.isPregnancy
          ? "Hi! I'm here to support you through your pregnancy. Ask me anything."
          : "Hi! I'm here to help you and your little one. Ask me anything.";

      _messages.add(ChatMessage(sender: ChatSender.bot, text: greeting));
      notifyListeners();
    }
  }

  Future<void> send(String userText) async {
    if (_context == null) return;
    if (_isTyping) return;

    _messages.add(ChatMessage(sender: ChatSender.user, text: userText));
    notifyListeners();

    _isTyping = true;
    notifyListeners();

    try {
      final fullReply = await chatService.sendMessage(
        message: userText,
        context: _context!,
      );

      if (fullReply.trim().isEmpty) throw Exception('Empty response');

      await _streamBotReply(fullReply);
    } catch (e) {
      debugPrint('CHAT ERROR: $e');
      _isTyping = false;
      _messages.add(
        const ChatMessage(
          sender: ChatSender.bot,
          text: 'Sorry, something went wrong. Please try again.',
        ),
      );
      notifyListeners();
    }
  }

  Future<void> _streamBotReply(String fullText) async {
    _isTyping = false;

    final words = fullText.split(' ');
    String currentText = '';

    _messages.add(const ChatMessage(sender: ChatSender.bot, text: ''));
    notifyListeners();

    for (final word in words) {
      await Future.delayed(const Duration(milliseconds: 120));
      currentText = currentText.isEmpty ? word : '$currentText $word';
      _messages[_messages.length - 1] =
          _messages.last.copyWith(text: currentText);
      notifyListeners();
    }
  }
}
