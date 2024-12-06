import 'package:auto_route/auto_route.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/chat_bot.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_chat_view.dart';
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

  @override
  void dispose() {
    _chatController?.dispose();
    super.dispose();
  }

  void _loadChatHistory() async {
    try {
      final history = await _service.getChatHistory();
      final initialMessageList = <Message>[];

      for (var promptResponse in history) {
        final prompt = promptResponse.prompt;
        final responses = promptResponse.responses;

        initialMessageList.add(
          Message(
            id: const Uuid().v4(),
            message: prompt,
            sentBy: '1',
            createdAt: promptResponse.timestamp,
            status: MessageStatus.read,
          ),
        );

        for (var response in responses) {
          initialMessageList.add(
            Message(
              id: const Uuid().v4(),
              message: response,
              sentBy: '2',
              createdAt: promptResponse.timestamp,
              status: MessageStatus.read,
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
    } catch (e, stackTrace) {
      _log.e("Error loading chat history", error: e, stackTrace: stackTrace);
      _chatViewState = ChatViewState.error;
    }
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      showLeading: false,
      actionButton: SonaActionButton.home(),
      padding: 0,
      body: _chatController == null
          ? const Center(child: CircularProgressIndicator())
          : SonaChatView(
              chatController: _chatController!,
              chatViewState: _chatViewState,
              sendMessage: _sendMessage,
              enableCameraImagePicker: false,
              enableGalleryImagePicker: false,
              allowRecordingVoice: false,
            ),
    );
  }

  void _sendMessage(String message, ReplyMessage replyMessage, MessageType messageType) async {
    final messageSent = Message(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      message: message,
      sentBy: _chatController!.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
      status: MessageStatus.pending,
    );

    _chatController!.addMessage(messageSent);

    if (_chatViewState == ChatViewState.noData) {
      _chatViewState = ChatViewState.hasMessages;
      refresh();
    }

    try {
      final response = await _service.sendMessage(message);

      messageSent.setStatus = MessageStatus.read;

      final responses = response.responses;
      for (var response in responses) {
        _chatController!.addMessage(
          Message(
            id: const Uuid().v4(),
            message: response,
            sentBy: '2',
            createdAt: DateTime.now(),
            status: MessageStatus.read,
          ),
        );
      }
    } catch (e) {
      _log.e(e);
      messageSent.setStatus = MessageStatus.undelivered;
    }
  }
}
