import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';
import '../../models/chat_stage.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets/typing_dots.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;

  // FAQ lists
  final List<String> pregnancyFaq = [
    "What foods should I eat in the first trimester?",
    "Is it safe to exercise during pregnancy?",
    "How much weight gain is normal?",
    "What vitamins should I take during pregnancy?",
    "How to reduce morning sickness?",
  ];

  final List<String> postpartumFaq = [
    "How often should I breastfeed my baby?",
    "Why does my baby wake up at night?",
    "How long does postpartum recovery take?",
    "How to increase breast milk supply?",
    "How to soothe a crying baby?",
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

    if (chatProvider.context != null && chatProvider.context!.userId != user.id) {
      chatProvider.reset();
    }

    if (chatProvider.context != null) return;

    if (user.stage == UserStage.pregnancy) {
      int? trimester;
      if (user.pregnancyDetails != null) {
        final dueDate = user.pregnancyDetails!.expectedDueDate;
        final weeksLeft = dueDate.difference(DateTime.now()).inDays ~/ 7;
        final weeksPregnant = 40 - weeksLeft;
        if (weeksPregnant <= 12) trimester = 1;
        else if (weeksPregnant <= 26) trimester = 2;
        else trimester = 3;
      }
      chatProvider.initialize(ChatContext(
        userId: user.id,
        stage: 'pregnancy',
        trimester: trimester,
      ));
    } else {
      // postpartum
      int? babyAgeMonths;
      if (user.babyDetails != null) {
        final dob = user.babyDetails!.dateOfBirth;
        final now = DateTime.now();
        babyAgeMonths = (now.year - dob.year) * 12 + (now.month - dob.month);
      }
      chatProvider.initialize(ChatContext(
        userId: user.id,
        stage: 'postpartum',
        babyAgeMonths: babyAgeMonths,
        babyName: user.babyDetails?.name,
        feedingType: user.babyDetails?.feedingType,
        deliveryType: user.babyDetails?.deliveryType,
      ));
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

  // FAQ chips
  Widget _buildFAQChips(ChatProvider chat) {
    // Hide after first user message
    if (chat.messages.length > 1) return const SizedBox.shrink();

    final isPregnancy = chat.context?.isPregnancy ?? false;
    final questions = isPregnancy ? pregnancyFaq : postpartumFaq;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: questions.map((q) {
          return GestureDetector(
            onTap: () => chat.send(q),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              constraints: const BoxConstraints(maxWidth: 260),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                q,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
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
                itemCount:
                chat.messages.length + (chat.isTyping ? 1 : 0),
                itemBuilder: (_, index) {
                  if (chat.isTyping && index == chat.messages.length) {
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

                  final msg = chat.messages[index];
                  final isUser = msg.sender == ChatSender.user;

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
                          child: Text(
                            msg.text,
                            softWrap: true,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              height: 1.4,
                              fontSize: 14,
                              color: isUser
                                  ? Colors.white
                                  : AppColors.textPrimary,
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration:
                const InputDecoration(hintText: 'Ask anything...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_controller.text.trim().isEmpty) return;
                chat.send(_controller.text.trim());
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
