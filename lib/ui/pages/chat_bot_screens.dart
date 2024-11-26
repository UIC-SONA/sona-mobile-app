import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/promp_response.dart';
import 'package:sona/domain/services/chat_bot.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';
import 'package:uuid/uuid.dart';

final Logger _log = Logger();

@RoutePage()
class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends FullState<ChatBotScreen> {
  final _service = injector.get<ChatBotService>();

  ChatController? _chatController;
  ChatViewState _chatViewState = ChatViewState.loading;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _loadChatHistory() async {
    try {
      final history = await _service.getChatHistory();
      final initialMessageList = <Message>[];

      for (PromptResponse promptResponse in history) {
        final String prompt = promptResponse.prompt;
        final List<String> responses = promptResponse.responses;

        initialMessageList.add(
          Message(
            id: const Uuid().v4(),
            message: prompt,
            sentBy: '1',
            createdAt: promptResponse.timestamp,
          ),
        );

        for (String response in responses) {
          initialMessageList.add(
            Message(
              id: const Uuid().v4(),
              message: response,
              sentBy: '2',
              createdAt: promptResponse.timestamp,
            ),
          );
        }
      }

      _chatController = ChatController(
        currentUser: ChatUser(
          id: '1',
          name: 'Tú',
        ),
        otherUsers: [
          ChatUser(
            id: '2',
            name: 'Sona Bot',
          ),
        ],
        initialMessageList: initialMessageList,
        scrollController: ScrollController(),
      );

      _chatViewState = initialMessageList.isEmpty ? ChatViewState.noData : ChatViewState.hasMessages;
    } catch (e) {
      _log.e(e);
      _chatViewState = ChatViewState.error;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      showLeading: false,
      actionButton: SonaActionButton.home(),
      body: _chatController == null
          ? const Center(child: CircularProgressIndicator())
          : ChatView(
              chatController: _chatController!,
              chatViewState: _chatViewState,
              appBar: const ChatViewAppBar(
                chatTitle: 'Sona Bot',
              ),
            ),
    );
  }
}
