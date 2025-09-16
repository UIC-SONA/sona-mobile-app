import 'package:auto_route/auto_route.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/chat_bot.dart';
import 'package:sona/ui/theme/colors.dart';
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
  final _chatBotService = injector.get<ChatBotService>();

  final ChatController _chatController = ChatController(
    initialMessageList: [],
    scrollController: ScrollController(),
    otherUsers: [
      ChatUser(
        id: '2',
        name: 'Sona Bot',
      ),
    ],
    currentUser: ChatUser(
      id: '1',
      name: 'Tú',
    ),
  );

  ChatViewState _chatViewState = ChatViewState.loading;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _loadChatHistory() async {
    try {
      final history = await _chatBotService.getChatHistory();
      final initialMessageList = <Message>[];

      for (var promptResponse in history) {
        final prompt = promptResponse.prompt;
        final responses = promptResponse.responses;

        initialMessageList.add(Message(
          id: const Uuid().v4(),
          message: prompt,
          sentBy: '1',
          createdAt: promptResponse.timestamp,
          status: MessageStatus.read,
        ));

        for (var response in responses) {
          initialMessageList.add(Message(
            id: const Uuid().v4(),
            message: response,
            sentBy: '2',
            createdAt: promptResponse.timestamp,
            status: MessageStatus.read,
          ));
        }
      }

      _chatController.loadMoreData(initialMessageList);
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
      bgGradient: bgGradientBackChatbot,
      showLeading: false,
      hideBgLogo: true,
      actionButton: SonaActionButton.home(),
      padding: 0,
      body: Column(
        children: [
          Expanded(
            child: SonaChatView(
              chatController: _chatController,
              chatViewState: _chatViewState,
              sendMessage: _sendMessage,
              enableCameraPicker: false,
              enableGalleryPicker: false,
              allowRecordingVoice: false,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Tus consultas están siendo utilizadas para retroalimentar a la Inteligencia Artificial. Considera que este bot puede cometer errores, no es 100% confiable.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _sendMessage(String message, ReplyMessage replyMessage, MessageType messageType, {String? customType}) async {
    final messageSent = Message(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      message: message,
      sentBy: _chatController.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
      status: MessageStatus.pending,
    );

    _chatController.addMessage(messageSent);

    if (_chatViewState == ChatViewState.noData) {
      _chatViewState = ChatViewState.hasMessages;
      refresh();
    }

    try {
      final response = await _chatBotService.sendMessage(message);

      messageSent.setStatus = MessageStatus.read;

      final responses = response.responses;
      for (var response in responses) {
        _chatController.addMessage(Message(
          id: const Uuid().v4(),
          message: response,
          sentBy: '2',
          createdAt: DateTime.now(),
          status: MessageStatus.read,
        ));
      }
    } catch (e) {
      _log.e(e);
      messageSent.setStatus = MessageStatus.undelivered;
    }
  }
}
