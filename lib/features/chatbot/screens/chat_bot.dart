import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:logger/logger.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sona/application/theme/colors.dart';
import 'package:sona/application/widgets/sona_scaffold.dart';
import 'package:sona/features/chatbot/services/chatbot_client.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

final Logger _log = Logger();

final _messages = <types.Message>[];
final _user = types.User(firstName: "Tú", id: const Uuid().v4());

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  //
  var _isSending = false;

  //
  final _chatBot = const types.User(firstName: "SonaBot", id: 'SonaBot');

  //
  final _chatClient = ChatbotClient(projectId: 'elated-cathode-438218-g7', agentId: '4c534ade-f1a6-4b64-a46f-23d5814ca66c', location: 'global');

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {}

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    _log.d('Message tapped: ${message.runtimeType},content: ${message.toJson()}');
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index = _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage = (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index = _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage = (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    if (message.text.isEmpty) return;
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    _sendMessage(message.text).catchError((Object e, StackTrace s) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar el mensaje: $e'),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: () {
              _handleSendPressed(message);
            },
          ),
        ),
      );
    }).whenComplete(() {
      setState(() {
        _isSending = false;
      });
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    final response = await _chatClient.sendMessage(_user.id, message);

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message,
    );

    _addMessage(textMessage);

    setState(() {
      _addMessage(
        types.TextMessage(
          author: _chatBot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: response,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      showLeading: false,
      actionButton: SonaActionButton.home(),
      body: Chat(
        avatarBuilder: (types.User user) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: const CircleAvatar(
              backgroundColor: primaryColor,
              child: Icon(Icons.android),
            ),
          );
        },
        theme: DefaultChatTheme(
          backgroundColor: Colors.transparent,
          inputBackgroundColor: Colors.white,
          inputTextColor: Colors.black,
          primaryColor: deepMagenta,
          secondaryColor: deepMagenta,
          inputPadding: const EdgeInsets.all(0),
          inputBorderRadius: BorderRadius.circular(0),
          inputTextDecoration: const InputDecoration(
            hintText: 'Escribe un mensaje...',
            hintStyle: TextStyle(color: hintColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          messageInsetsVertical: 10,
          messageInsetsHorizontal: 10,
          messageBorderRadius: 10,
          receivedMessageBodyTextStyle: const TextStyle(color: Colors.white),
          sentMessageBodyBoldTextStyle: const TextStyle(color: Colors.white),
          bubbleMargin: const EdgeInsets.symmetric(vertical: 1),
        ),
        messages: _messages,
        //onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
      ),
    );
  }
}
