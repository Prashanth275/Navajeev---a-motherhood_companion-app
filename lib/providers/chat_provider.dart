import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/chat_stage.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  ChatContext? _context;

  ChatProvider({ChatService? service}) : _chatService = service ?? chatService;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isSending => _isTyping;
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

  void updateContext(ChatContext newContext) {
    if (_context?.userId != newContext.userId) {
      reset();
      initialize(newContext);
      return;
    }
    _context = newContext;
    notifyListeners();
  }

  void reset() {
    _context = null;
    _messages.clear();
    _isTyping = false;
    notifyListeners();
  }

  Future<void> send(String userText) async {
    final trimmed = userText.trim();
    if (trimmed.isEmpty) return;
    if (_context == null) return;
    if (_isTyping) return;

    _isTyping = true;
    _messages.add(ChatMessage(sender: ChatSender.user, text: trimmed));

    final botMessageIndex = _messages.length;
    _messages.add(const ChatMessage(sender: ChatSender.bot, text: ''));
    notifyListeners();

    try {
      final fullReply = await _chatService.sendMessage(
        message: trimmed,
        context: _context,
      );

      if (fullReply.trim().isEmpty) throw Exception('Empty response');

      final cleanedReply = cleanDocumentPhrases(fullReply);
      await _streamBotReply(cleanedReply, botMessageIndex);
    } catch (e) {
      debugPrint('CHAT ERROR: $e');
      if (botMessageIndex < _messages.length &&
          _messages[botMessageIndex].sender == ChatSender.bot) {
        _messages[botMessageIndex] = const ChatMessage(
          sender: ChatSender.bot,
          text: 'Sorry, something went wrong. Please try again.',
        );
      } else {
        _messages.add(
          const ChatMessage(
            sender: ChatSender.bot,
            text: 'Sorry, something went wrong. Please try again.',
          ),
        );
      }
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> _streamBotReply(String fullText, int botMessageIndex) async {
    final words = fullText.split(' ');
    String currentText = '';

    for (final word in words) {
      await Future.delayed(const Duration(milliseconds: 60));
      currentText = currentText.isEmpty ? word : '$currentText $word';
      if (botMessageIndex < _messages.length &&
          _messages[botMessageIndex].sender == ChatSender.bot) {
        _messages[botMessageIndex] =
            _messages[botMessageIndex].copyWith(text: currentText);
        notifyListeners();
      }
    }
  }

  /// Removes internal RAG document references from user-facing responses
  /// while preserving factual health guidance and grounding.
  static String cleanDocumentPhrases(String text) {
    var cleaned = text;

    cleaned = cleaned.replaceAll(
      RegExp(
        r',\s*(?:taken\s+straight\s+from|based\s+on|according\s+to|as\s+stated\s+in|as\s+mentioned\s+in|found\s+in)\s+(?:the\s+information\s+in\s+)?(?:the|this|the\s+provided)\s+document\s*:',
        caseSensitive: false,
      ),
      ':',
    );

    cleaned = cleaned.replaceAll(
      RegExp(
        r'\s*\((?:taken\s+straight\s+from|based\s+on|according\s+to)\s+(?:the\s+information\s+in\s+)?(?:the|this|the\s+provided)\s+document\)',
        caseSensitive: false,
      ),
      '',
    );

    cleaned = cleaned.replaceAll(
      RegExp(
        r'^(?:According\s+to|Based\s+on|As\s+stated\s+in|As\s+mentioned\s+in|From)\s+(?:the\s+information\s+in\s+)?(?:the|this|the\s+provided)\s+document,?\s*',
        caseSensitive: false,
        multiLine: true,
      ),
      '',
    );

    cleaned = cleaned.replaceAll(
      RegExp(
        r'\b(?:taken\s+straight\s+from|straight\s+from)\s+(?:the\s+information\s+in\s+)?(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      '',
    );

    cleaned = cleaned.replaceAll(
      RegExp(
        r'\bthe\s+information\s+in\s+(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      'the health guidance',
    );

    cleaned = cleaned.replaceAll(
      RegExp(
        r'\baccording\s+to\s+(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      'according to guidance',
    );

    cleaned = cleaned.replaceAll(
      RegExp(
        r'\bbased\s+on\s+(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      'based on guidance',
    );

    cleaned = cleaned.replaceAll(
      RegExp(
        r'\bin\s+(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      'in our guidance',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(
        r'\b(?:the|this|the\s+provided)\s+document\s+(states|suggests|recommends|mentions|advises|explains|notes|says|indicates|shows)\b',
        caseSensitive: false,
      ),
      (match) => 'Guidance ${match.group(1)}',
    );

    cleaned = cleaned.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    cleaned = cleaned.trim();
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    return cleaned;
  }
}
