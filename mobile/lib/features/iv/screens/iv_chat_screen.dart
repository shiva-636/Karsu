import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/app_theme.dart';

class IvChatScreen extends StatefulWidget {
  const IvChatScreen({super.key});

  @override
  State<IvChatScreen> createState() => _IvChatScreenState();
}

class ChatItem {
  ChatItem(
    this.user,
    this.text, {
    this.structured,
  });

  final bool user;
  final String text;
  final Map<String, dynamic>? structured;
}

class _IvChatScreenState extends State<IvChatScreen> {
  final controller = TextEditingController();
  final scroll = ScrollController();

  bool sending = false;

  final messages = <ChatItem>[
    ChatItem(
      false,
      'I’m IV. I help you decide what to do next — based on your business context, not generic advice.',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = controller.text.trim();

    if (text.isEmpty || sending) {
      return;
    }

    setState(() {
      messages.add(
        ChatItem(true, text),
      );
    });

    controller.clear();

    setState(() {
      sending = true;
    });

    try {
      final r = await apiClient.post(
        '/iv/ask',
        {
          'message': text,
          'mode': 'ask',
        },
      );

      if (mounted) {
        setState(() {
          messages.add(
            ChatItem(
              false,
              r['recommendation']?.toString() ??
                  'I could not generate a response.',
              structured: r,
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          messages.add(
            ChatItem(
              false,
              'I can’t reach the KARSU API right now. Check your connection or API URL.',
            ),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }

      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (scroll.hasClients) {
            scroll.animateTo(
              scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'IV',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'BUSINESS COACH',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scroll,
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  return _bubble(messages[index]);
                },
              ),
            ),
            if (sending)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'IV is thinking…',
                  style: TextStyle(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                'AI can be wrong. Verify important decisions and current information.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: 4,
                      minLines: 1,
                      onSubmitted: (_) => send(),
                      decoration: const InputDecoration(
                        hintText: 'Ask IV anything…',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: send,
                    icon: const Icon(
                      Icons.arrow_upward,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(ChatItem item) {
    final structured = item.structured;

    return Align(
      alignment: item.user
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: item.user
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: item.user
              ? null
              : Border.all(
                  color: AppColors.border,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.text,
              style: TextStyle(
                color: item.user
                    ? Colors.white
                    : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            if (structured != null && !item.user) ...[
              const SizedBox(height: 14),
              _section(
                'Why',
                structured['why'],
              ),
              _section(
                'Risks',
                structured['risks'],
              ),
              _section(
                'Alternatives',
                structured['alternatives'],
              ),
              _section(
                'Next action',
                structured['nextAction'],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _section(
    String title,
    dynamic value,
  ) {
    if (value == null) {
      return const SizedBox.shrink();
    }

    final text = value is List
        ? value.map((e) => '• $e').join('\n')
        : value.toString();

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBright,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
