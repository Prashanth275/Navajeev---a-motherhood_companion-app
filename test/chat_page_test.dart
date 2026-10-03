import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:navajeev_m/models/chat_stage.dart';
import 'package:navajeev_m/models/user_model.dart';
import 'package:navajeev_m/providers/chat_provider.dart';
import 'package:navajeev_m/screens/chatbot/chat_page.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:navajeev_m/services/chat_service.dart';
import 'package:navajeev_m/widgets/app_widgets/typing_dots.dart';
import 'package:navajeev_m/widgets/app_widgets/faq_glass_card.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MockAuthService extends ChangeNotifier implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  UserModel? get currentUser => null;
}

class MockChatService implements ChatService {
  Completer<String>? pendingCompleter;
  bool shouldThrow = false;
  String responseText = "Default answer";

  @override
  String get baseUrl => '';

  @override
  Future<String> sendMessage({
    required String message,
    ChatContext? context,
  }) async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    if (pendingCompleter != null) {
      return pendingCompleter!.future;
    }
    return responseText;
  }
}

void main() {
  group('ChatPage Widget & Single Bubble Lifecycle Tests', () {
    Future<void> pumpChatPage(
      WidgetTester tester, {
      required ChatProvider chatProvider,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
              ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService()),
            ],
            child: const Scaffold(body: ChatPage()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('TEST 1: Normal question - exactly 1 user bubble, 1 bot bubble, no leftover typing dots', (tester) async {
      final mockService = MockChatService();
      final completer = Completer<String>();
      mockService.pendingCompleter = completer;

      final chatProvider = ChatProvider(service: mockService);
      chatProvider.initialize(ChatContext(userId: 'u1', stage: 'pregnancy', trimester: 1));
      await pumpChatPage(tester, chatProvider: chatProvider);

      // Initial state: greeting only
      expect(find.byType(TypingDots), findsNothing);
      expect(chatProvider.messages.length, 1);

      // Send question
      chatProvider.send("How can I get better sleep?");
      await tester.pump();

      // In-flight state: 1 greeting, 1 user, 1 bot placeholder (showing TypingDots)
      expect(chatProvider.isTyping, isTrue);
      expect(find.byType(TypingDots), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);

      // Complete response
      completer.complete("Sleep on your left side and use a pillow between your knees.");
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 70));
      }

      // Post-completion: exactly 1 user bubble, 1 bot response bubble, 0 leftover TypingDots
      expect(chatProvider.isTyping, isFalse);
      expect(find.byType(TypingDots), findsNothing);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
      expect(find.text("How can I get better sleep?"), findsOneWidget);
      expect(find.byType(MarkdownBody), findsNWidgets(2)); // greeting + answer
    });

    testWidgets('TEST 2: Vaccine question - "What vaccines does a baby need?" renders correctly without extra bubble', (tester) async {
      final mockService = MockChatService();
      mockService.responseText = "1. At birth: BCG, Polio zero dose, Hepatitis B.\n2. 6-10-14 weeks: Pentavalent and Rotavirus.\n3. 9-12 months: Measles-Rubella.";

      final chatProvider = ChatProvider(service: mockService);
      chatProvider.initialize(ChatContext(userId: 'u1', stage: 'pregnancy', trimester: 1));
      await pumpChatPage(tester, chatProvider: chatProvider);

      chatProvider.send("What vaccines does a baby need?");
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 70));
      }

      expect(chatProvider.isTyping, isFalse);
      expect(find.byType(TypingDots), findsNothing);
      expect(find.text("What vaccines does a baby need?"), findsOneWidget);
      expect(chatProvider.messages.last.text, contains("BCG"));
      expect(chatProvider.messages.last.text, contains("Pentavalent"));
    });

    testWidgets('TEST 3: Morning sickness question renders single answer bubble', (tester) async {
      final mockService = MockChatService();
      mockService.responseText = "To help with morning sickness: eat small frequent meals and stay hydrated.";

      final chatProvider = ChatProvider(service: mockService);
      chatProvider.initialize(ChatContext(userId: 'u1', stage: 'pregnancy', trimester: 1));
      await pumpChatPage(tester, chatProvider: chatProvider);

      chatProvider.send("How to reduce morning sickness?");
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 70));
      }

      expect(chatProvider.isTyping, isFalse);
      expect(find.byType(TypingDots), findsNothing);
      expect(find.text("How to reduce morning sickness?"), findsOneWidget);
      expect(chatProvider.messages.last.text, contains("morning sickness"));
    });

    testWidgets('TEST 4: Pregnancy food question renders single answer bubble', (tester) async {
      final mockService = MockChatService();
      mockService.responseText = "Eat nutrient-dense foods including pulses, green vegetables, milk, and seasonal fruits.";

      final chatProvider = ChatProvider(service: mockService);
      chatProvider.initialize(ChatContext(userId: 'u1', stage: 'pregnancy', trimester: 2));
      await pumpChatPage(tester, chatProvider: chatProvider);

      chatProvider.send("What foods should I eat?");
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 70));
      }

      expect(chatProvider.isTyping, isFalse);
      expect(find.byType(TypingDots), findsNothing);
      expect(find.text("What foods should I eat?"), findsOneWidget);
      expect(chatProvider.messages.last.text, contains("nutrient-dense"));
    });

    testWidgets('TEST 5: Long response question completes streaming without duplicate bubbles', (tester) async {
      final mockService = MockChatService();
      mockService.responseText = "Postpartum wellbeing is vital. Get adequate rest whenever your baby sleeps. Accept support from family members. Maintain balanced nutrition with iron and calcium. Stay hydrated and speak to your doctor if you experience persistent sadness.";

      final chatProvider = ChatProvider(service: mockService);
      chatProvider.initialize(ChatContext(userId: 'u1', stage: 'postpartum', babyAgeMonths: 2));
      await pumpChatPage(tester, chatProvider: chatProvider);

      chatProvider.send("How can I support my wellbeing after giving birth?");
      await tester.pump();

      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 70));
      }

      expect(chatProvider.isTyping, isFalse);
      expect(find.byType(TypingDots), findsNothing);
      expect(find.text("How can I support my wellbeing after giving birth?"), findsOneWidget);
      expect(chatProvider.messages.last.text, contains("Postpartum wellbeing is vital"));
    });

    testWidgets('TEST 6: Network error replaces placeholder with error message and re-enables input', (tester) async {
      final mockService = MockChatService();
      mockService.shouldThrow = true;

      final chatProvider = ChatProvider(service: mockService);
      chatProvider.initialize(ChatContext(userId: 'u1', stage: 'pregnancy'));
      await pumpChatPage(tester, chatProvider: chatProvider);

      chatProvider.send("This will fail");
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(chatProvider.isTyping, isFalse);
      expect(find.byType(TypingDots), findsNothing);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
      expect(find.text("Sorry, something went wrong. Please try again."), findsOneWidget);
      expect(chatProvider.messages.length, 3); // Greeting + User + Error Bot
    });
  });

  group('FAQ Glassmorphism & Responsive 4x2 Grid Tests', () {
    Future<void> pumpChatPage(
      WidgetTester tester, {
      required ChatProvider chatProvider,
      Size size = const Size(1000, 800),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
              ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService()),
            ],
            child: const Scaffold(body: ChatPage()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('TEST 7: Pregnancy mode displays exactly 8 glass FAQ cards with identical dimensions', (tester) async {
      final mockService = MockChatService();
      final chatProvider = ChatProvider(service: mockService);
      chatProvider.initialize(ChatContext(userId: 'u1', stage: 'pregnancy', trimester: 2));

      await pumpChatPage(tester, chatProvider: chatProvider, size: const Size(1000, 800));

      final faqCardsFinder = find.byType(FaqGlassCard);
      expect(faqCardsFinder, findsNWidgets(8));

      // Verify all 8 questions match the required list
      final expectedQuestions = [
        "What foods should I eat?",
        "Is it safe to exercise during pregnancy?",
        "How can I get better sleep during pregnancy?",
        "What are the labor signs?",
        "How can I deal with nausea and vomiting during pregnancy?",
        "What should I do if I feel tired or nauseated during pregnancy?",
        "What checkups and tests are recommended during pregnancy?",
        "What should I do to prepare for labor and birth?",
      ];

      for (final q in expectedQuestions) {
        expect(find.text(q), findsOneWidget);
      }

      // Verify all 8 cards have identical height and width
      final firstSize = tester.getSize(faqCardsFinder.first);
      for (int i = 1; i < 8; i++) {
        final cardSize = tester.getSize(faqCardsFinder.at(i));
        expect(cardSize.width, equals(firstSize.width));
        expect(cardSize.height, equals(firstSize.height));
      }

      // Verify glassmorphism components
      expect(find.byType(BackdropFilter), findsWidgets);
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('TEST 8: Postpartum mode displays exactly 8 postpartum glass FAQ cards', (tester) async {
      final mockService = MockChatService();
      final chatProvider = ChatProvider(service: mockService);
      chatProvider.initialize(ChatContext(userId: 'u1', stage: 'postpartum', babyAgeMonths: 3));

      await pumpChatPage(tester, chatProvider: chatProvider, size: const Size(1000, 800));

      final faqCardsFinder = find.byType(FaqGlassCard);
      expect(faqCardsFinder, findsNWidgets(8));

      final expectedPostpartum = [
        "What is colostrum and why is it important?",
        "Why does my baby wake up at night?",
        "How can I support my wellbeing after giving birth?",
        "How to increase breast milk supply?",
        "How to soothe a crying baby?",
        "What baby clothes are recommended for a newborn?",
        "What skin changes are normal in newborns?",
        "What checkups should I have after giving birth?",
      ];

      for (final q in expectedPostpartum) {
        expect(find.text(q), findsOneWidget);
      }
    });

    testWidgets('TEST 9: Tapping an FAQ glass card sends question and hides FAQ grid after response', (tester) async {
      final mockService = MockChatService();
      mockService.responseText = "Colostrum is the first milk produced after birth, rich in antibodies.";
      final chatProvider = ChatProvider(service: mockService);
      chatProvider.initialize(ChatContext(userId: 'u1', stage: 'postpartum', babyAgeMonths: 1));

      await pumpChatPage(tester, chatProvider: chatProvider, size: const Size(1000, 800));

      expect(find.byType(FaqGlassCard), findsNWidgets(8));

      // Tap on the first card
      await tester.tap(find.text("What is colostrum and why is it important?"));
      await tester.pump();

      // Pump through streaming
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 70));
      }

      // After user message is sent, FAQ section must be hidden
      expect(find.byType(FaqGlassCard), findsNothing);
      expect(find.text("What is colostrum and why is it important?"), findsOneWidget);
      expect(chatProvider.messages.last.text, contains("Colostrum is the first milk"));
    });
  });
}
