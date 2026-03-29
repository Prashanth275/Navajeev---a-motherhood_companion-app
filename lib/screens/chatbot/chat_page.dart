import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';
import '../../theme/app_colors.dart';
import 'package:navajeev_m/models/chat_stage.dart';
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
  final List<String> pregnancyFaq = [
    "What foods should I eat in the first trimester?",
    "Is it safe to exercise during pregnancy?",
    "How much weight gain is normal?",
    "What vitamins should I take during pregnancy?",
    "How to reduce morning sickness?"
  ];

  final List<String> postpartumFaq = [
    "How often should I breastfeed my baby?",
    "Why does my baby wake up at night?",
    "How long does postpartum recovery take?",
    "How to increase breast milk supply?",
    "How to soothe a crying baby?"
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final chatProvider =
    Provider.of<ChatProvider>(context, listen: false);

    chatProvider.initialize(
      ChatContext(
        stage: 'postpartum',
        babyAgeMonths: 3,
      ),
    );

    _initialized = true;
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
    if (chat.messages.length > 1) return const SizedBox();

    final stage = chat.messages.isNotEmpty ? 'postpartum' : 'postpartum';

    final questions =
    stage == 'pregnant' ? pregnancyFaq : postpartumFaq;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: questions.map((q) {
          return GestureDetector(
            onTap: () {
              chat.send(q);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              constraints: const BoxConstraints(maxWidth: 260),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                  // Typing indicator
                  if (chat.isTyping &&
                      index == chat.messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin:
                        const EdgeInsets.only(bottom: 12),
                        padding:
                        const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:
                          BorderRadius.circular(18),
                        ),
                        child: const TypingDots(),
                      ),
                    );
                  }

                  final msg = chat.messages[index];
                  final isUser =
                      msg.sender == ChatSender.user;

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin:
                      const EdgeInsets.only(bottom: 12),
                      padding:
                      const EdgeInsets.all(14),
                      constraints: BoxConstraints(
                        maxWidth:
                        MediaQuery.of(context)
                            .size
                            .width * 0.80,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.primaryAccent
                            : Colors.grey.shade100,
                        borderRadius:
                        BorderRadius.circular(18),
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
                decoration: const InputDecoration(
                  hintText: "Ask anything...",
                ),
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