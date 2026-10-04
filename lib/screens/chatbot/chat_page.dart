import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';
import '../../models/chat_stage.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets/typing_dots.dart';
import '../../widgets/app_widgets/faq_glass_card.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();

  // FAQ lists
  final List<String> pregnancyFaq = [
    "What foods should I eat?",
    "Is it safe to exercise during pregnancy?",
    "How can I get better sleep during pregnancy?",
    "What are the labor signs?",
    "How can I deal with nausea and vomiting during pregnancy?",
    "When can I feel my baby's movements?",
    "What checkups and tests are recommended during pregnancy?",
    "What should I do to prepare for labor and birth?",
  ];

  final List<String> postpartumFaq = [
    "What is colostrum and why is it important?",
    "Why does my baby wake up at night?",
    "How can I support my wellbeing after giving birth?",
    "How to increase breast milk supply?",
    "How to soothe my crying baby?",
    "What baby clothes are recommended for my baby?",
    "What skin changes are normal in newborns?",
    "What checkups should I have after giving birth?",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeFromAuth();
  }

  void _initializeFromAuth() {
    final chatProvider = context.read<ChatProvider>();

    final authService = Provider.of<AuthService>(context, listen: true);
    final user = authService.currentUser;
    if (user == null) return;

    ChatContext targetContext;
    if (user.stage == UserStage.pregnancy) {
      int? trimester;
      if (user.pregnancyDetails != null) {
        final dueDate = user.pregnancyDetails!.expectedDueDate;
        final weeksLeft = dueDate.difference(DateTime.now()).inDays ~/ 7;
        final weeksPregnant = 40 - weeksLeft;
        if (weeksPregnant <= 12) {
          trimester = 1;
        } else if (weeksPregnant <= 26) {
          trimester = 2;
        } else {
          trimester = 3;
        }
      }
      targetContext = ChatContext(
        userId: user.id,
        stage: 'pregnancy',
        trimester: trimester,
      );
    } else {
      // postpartum
      int? babyAgeMonths;
      if (user.babyDetails != null) {
        final dob = user.babyDetails!.dateOfBirth;
        final now = DateTime.now();
        babyAgeMonths = (now.year - dob.year) * 12 + (now.month - dob.month);
      }
      targetContext = ChatContext(
        userId: user.id,
        stage: 'postpartum',
        babyAgeMonths: babyAgeMonths,
        babyName: user.babyDetails?.name,
        feedingType: user.babyDetails?.feedingType,
        deliveryType: user.babyDetails?.deliveryType,
      );
    }

    final currentContext = chatProvider.context;
    if (currentContext == null) {
      chatProvider.initialize(targetContext);
    } else if (currentContext != targetContext) {
      chatProvider.updateContext(targetContext);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildFAQChips(ChatProvider chat) {
    if (chat.messages.length > 1) return const SizedBox.shrink();

    final isPregnancy = chat.context?.isPregnancy ?? false;
    final questions = isPregnancy ? pregnancyFaq : postpartumFaq;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          int crossAxisCount;
          double mainAxisExtent;
          double spacing;

          if (width >= 750) {
            // Desktop / Web / Windows: Exactly 4 columns x 2 rows
            crossAxisCount = 4;
            mainAxisExtent = 74;
            spacing = 10;
          } else if (width >= 480) {
            // Tablet: 2 columns x 4 rows
            crossAxisCount = 2;
            mainAxisExtent = 70;
            spacing = 10;
          } else {
            // Mobile: 2 columns if width >= 340, else 1 column
            crossAxisCount = width >= 340 ? 2 : 1;
            mainAxisExtent = crossAxisCount == 1 ? 58 : 70;
            spacing = 8;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              mainAxisExtent: mainAxisExtent,
            ),
            itemBuilder: (context, index) {
              final q = questions[index];
              return FaqGlassCard(
                question: q,
                isBusy: chat.isTyping,
                onTap: chat.isTyping ? null : () => chat.send(q),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        _scrollToBottom();

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chat.messages.length,
                itemBuilder: (_, index) {
                  final msg = chat.messages[index];
                  final isUser = msg.sender == ChatSender.user;

                  if (!isUser && msg.text.isEmpty) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AnimatedAiAvatar(),
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(18),
                              ),
                            ),
                            child: const TypingDots(),
                          ),
                        ],
                      ),
                    );
                  }

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/ai_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(
                            maxWidth:
                            MediaQuery.of(context).size.width * 0.70,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppColors.primaryAccent
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isUser ? 18 : 0),
                              bottomRight: Radius.circular(isUser ? 0 : 18),
                            ),
                          ),
                          child: isUser
                              ? Text(
                            msg.text,
                            softWrap: true,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              height: 1.4,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          )
                              : MarkdownBody(
                            data: msg.text,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                height: 1.4,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              strong: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildFAQChips(chat),
            _buildInput(chat),
          ],
        );
      },
    );
  }

  Widget _buildInput(ChatProvider chat) {
    final isBusy = chat.isTyping;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !isBusy,
                textInputAction: TextInputAction.send,
                onSubmitted: isBusy
                    ? null
                    : (_) {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;
                        chat.send(text);
                        _controller.clear();
                      },
                decoration: InputDecoration(
                  hintText: isBusy ? 'Generating response...' : 'Ask anything...',
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: isBusy ? Colors.grey.shade400 : AppColors.primaryAccent,
              ),
              onPressed: isBusy
                  ? null
                  : () {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      chat.send(text);
                      _controller.clear();
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedAiAvatar extends StatefulWidget {
  const AnimatedAiAvatar({super.key});

  @override
  State<AnimatedAiAvatar> createState() => _AnimatedAiAvatarState();
}

class _AnimatedAiAvatarState extends State<AnimatedAiAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withValues(alpha: 0.25 * (1.0 - _controller.value)),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/ai_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
