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

    // Add ONE bot placeholder message; empty text indicates loading state
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

    // 1. Preamble clauses: ", taken straight from the information in the document:" -> ":"
    cleaned = cleaned.replaceAll(
      RegExp(
        r',\s*(?:taken\s+straight\s+from|based\s+on|according\s+to|as\s+stated\s+in|as\s+mentioned\s+in|found\s+in)\s+(?:the\s+information\s+in\s+)?(?:the|this|the\s+provided)\s+document\s*:',
        caseSensitive: false,
      ),
      ':',
    );

    // 2. Parenthetical: "(taken straight from the document)" -> ""
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\s*\((?:taken\s+straight\s+from|based\s+on|according\s+to)\s+(?:the\s+information\s+in\s+)?(?:the|this|the\s+provided)\s+document\)',
        caseSensitive: false,
      ),
      '',
    );

    // 3. Leading sentence intros: "According to the document, " -> ""
    cleaned = cleaned.replaceAll(
      RegExp(
        r'^(?:According\s+to|Based\s+on|As\s+stated\s+in|As\s+mentioned\s+in|From)\s+(?:the\s+information\s+in\s+)?(?:the|this|the\s+provided)\s+document,?\s*',
        caseSensitive: false,
        multiLine: true,
      ),
      '',
    );

    // 4. "taken straight from the document" or "taken straight from the information in the document"
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\b(?:taken\s+straight\s+from|straight\s+from)\s+(?:the\s+information\s+in\s+)?(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      '',
    );

    // 5. "the information in the document" -> "the health guidance"
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\bthe\s+information\s+in\s+(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      'the health guidance',
    );

    // 6. "according to the document" -> "according to guidance"
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\baccording\s+to\s+(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      'according to guidance',
    );

    // 7. "based on the (provided )?document" -> "based on guidance"
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\bbased\s+on\s+(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      'based on guidance',
    );

    // 8. "in the (provided )?document" -> "in our guidance"
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\bin\s+(?:the|this|the\s+provided)\s+document\b',
        caseSensitive: false,
      ),
      'in our guidance',
    );

    // 9. "the (provided )?document states/suggests/recommends/says/indicates" -> "Guidance states/suggests/recommends"
    cleaned = cleaned.replaceAllMapped(
      RegExp(
        r'\b(?:the|this|the\s+provided)\s+document\s+(states|suggests|recommends|mentions|advises|explains|notes|says|indicates|shows)\b',
        caseSensitive: false,
      ),
      (match) => 'Guidance ${match.group(1)}',
    );

    // Clean up any double spaces or whitespace created by stripping
    cleaned = cleaned.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    cleaned = cleaned.trim();
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    return cleaned;
  }
}
