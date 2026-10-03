import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:navajeev_m/models/chat_model.dart';
import 'package:navajeev_m/models/chat_stage.dart';
import 'package:navajeev_m/providers/chat_provider.dart';
import 'package:navajeev_m/services/chat_service.dart';

class MockChatService implements ChatService {
  Completer<String>? pendingCompleter;
  bool shouldThrow = false;
  int callCount = 0;
  String responseText = "Here are the foods you can focus on in your 3rd trimester, taken straight from the information in the document:\n- Milk and curd\n- Fresh fruits";

  @override
  String get baseUrl => '';

  @override
  Future<String> sendMessage({
    required String message,
    ChatContext? context,
  }) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('Simulated network failure');
    }
    if (pendingCompleter != null) {
      return pendingCompleter!.future;
    }
    return responseText;
  }
}

void main() {
  group('ChatProvider & cleanDocumentPhrases Tests', () {
    test('TEST 1 & 5: Normal question and cleanDocumentPhrases cleans document meta-phrases', () async {
      final mock = MockChatService();
      final provider = ChatProvider(service: mock);
      final context = ChatContext(userId: 'u1', stage: 'pregnancy', trimester: 3);
      provider.initialize(context);

      expect(provider.messages.length, 1); // Greeting
      expect(provider.isTyping, isFalse);

      final sendFuture = provider.send("What foods should I eat during pregnancy?");
      expect(provider.isTyping, isTrue);
      expect(provider.messages.length, 3); // Greeting + User + Bot placeholder
      expect(provider.messages[1].sender, ChatSender.user);
      expect(provider.messages[1].text, "What foods should I eat during pregnancy?");
      expect(provider.messages[2].sender, ChatSender.bot);
      expect(provider.messages[2].text, "");

      await sendFuture;

      expect(provider.isTyping, isFalse);
      expect(provider.messages.length, 3);
      expect(provider.messages[2].sender, ChatSender.bot);
      expect(provider.messages[2].text, startsWith("Here are the foods you can focus on in your 3rd trimester:\n- Milk and curd"));
      expect(provider.messages[2].text.contains("document"), isFalse);
    });

    test('TEST 2 & 3: Rapid duplicate tap and sending while busy are blocked', () async {
      final mock = MockChatService();
      final completer = Completer<String>();
      mock.pendingCompleter = completer;

      final provider = ChatProvider(service: mock);
      final context = ChatContext(userId: 'u1', stage: 'pregnancy', trimester: 2);
      provider.initialize(context);

      // First send
      final firstSend = provider.send("Question 1");
      expect(provider.isTyping, isTrue);
      expect(provider.messages.length, 3); // Greeting + Q1 + Bot placeholder

      // Immediate second send (duplicate tap while answering)
      final secondSend = provider.send("Question 2");
      expect(provider.messages.length, 3); // Q2 must NOT be added
      expect(mock.callCount, 1); // Only 1 API call

      completer.complete("Answer to question 1");
      await firstSend;
      await secondSend;

      expect(provider.isTyping, isFalse);
      expect(provider.messages.length, 3); // Greeting + User Q1 + Bot A1
      expect(provider.messages[1].text, "Question 1"); // User bubble uncorrupted
      expect(provider.messages[2].text, "Answer to question 1"); // Bot bubble has answer
    });

    test('TEST 4: API failure resets isTyping and does not lock out user', () async {
      final mock = MockChatService();
      mock.shouldThrow = true;

      final provider = ChatProvider(service: mock);
      final context = ChatContext(userId: 'u1', stage: 'pregnancy');
      provider.initialize(context);

      await provider.send("Will this fail?");

      expect(provider.isTyping, isFalse);
      expect(provider.messages.length, 3); // Greeting + User Msg + Error Bot Msg
      expect(provider.messages.last.sender, ChatSender.bot);
      expect(provider.messages.last.text, "Sorry, something went wrong. Please try again.");

      // Verify user can immediately send another message after error
      mock.shouldThrow = false;
      mock.responseText = "Recovery success";
      await provider.send("Retry question");

      expect(provider.isTyping, isFalse);
      expect(provider.messages.last.text, "Recovery success");
    });

    test('TEST 5: Comprehensive document wording sanitization', () {
      expect(
        ChatProvider.cleanDocumentPhrases(
          "Here are the foods, taken straight from the information in the document:\n- Apples",
        ),
        equals("Here are the foods:\n- Apples"),
      );

      expect(
        ChatProvider.cleanDocumentPhrases(
          "According to the document, drink water.",
        ),
        equals("Drink water."),
      );

      expect(
        ChatProvider.cleanDocumentPhrases(
          "Based on the provided document, you can rest.",
        ),
        equals("You can rest."),
      );

      expect(
        ChatProvider.cleanDocumentPhrases(
          "The document says that walking helps with back pain.",
        ),
        equals("Guidance says that walking helps with back pain."),
      );
    });

    test('TEST 6: Context update synchronizes stage from pregnancy to postpartum without losing history', () {
      final mock = MockChatService();
      final provider = ChatProvider(service: mock);
      final pregContext = ChatContext(userId: 'u1', stage: 'pregnancy', trimester: 2);
      provider.initialize(pregContext);

      expect(provider.context!.stage, 'pregnancy');
      expect(provider.context!.toPromptPrefix(), 'The user is pregnant, Trimester 2.');

      // User transitions to postpartum
      final postContext = ChatContext(
        userId: 'u1',
        stage: 'postpartum',
        babyAgeMonths: 6,
        feedingType: 'breastfeeding',
      );
      provider.updateContext(postContext);

      expect(provider.context!.stage, 'postpartum');
      expect(
        provider.context!.toPromptPrefix(),
        'The user is postpartum (baby is 6 months old, feeding method is breastfeeding).',
      );
      // History preserved
      expect(provider.messages.length, 1);
    });

    test('TEST 7: Different user logs in resets chat provider history', () {
      final mock = MockChatService();
      final provider = ChatProvider(service: mock);
      provider.initialize(ChatContext(userId: 'user_A', stage: 'pregnancy'));
      expect(provider.messages.length, 1);

      // New user B logs in
      provider.updateContext(ChatContext(userId: 'user_B', stage: 'postpartum'));
      expect(provider.context!.userId, 'user_B');
      expect(provider.messages.length, 1); // Reset and re-initialized with new greeting
      expect(provider.messages.first.text, contains("little one"));
    });
  });
}
