import 'package:auto_route/annotations.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_chat_view.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class ChatRoomScreen extends StatefulWidget {
  final User profile;
  final ChatRoomData roomData;

  const ChatRoomScreen({
    super.key,
    required this.profile,
    required this.roomData,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

Logger _log = Logger();

class _ChatRoomScreenState extends FullState<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _messagesRequests = [];

  late final _chatService = injector.get<ChatService>();
  late final _chatViewState = valueState(ChatViewState.loading);
  late final ChatController _chatController = ChatController(
    initialMessageList: [],
    scrollController: _scrollController,
    otherUsers: _mapUsers(roomData.participants),
    currentUser: _mapUser(profile),
  );

  int _chunk = 1;
  bool _isLoadingMore = false;

  ChatRoomData get roomData => widget.roomData;

  User get profile => widget.profile;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _chatService.closeOnReceiveMessageRoom(roomId: roomData.id);
    _chatService.closeOnReadMessageRoom(roomId: roomData.id);
    super.dispose();
  }

  void _scrollListener() async {
    if (_isLoadingMore) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      await _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_chunk <= 1) return;

    try {
      _isLoadingMore = true;
      final nextChunk = _chunk - 1;

      final moreMessages = await _chatService.messages(
        roomId: roomData.id,
        chunk: nextChunk,
      );

      if (moreMessages.isNotEmpty) {
        _chunk = nextChunk;
        _chatController.loadMoreData(_mapMessages(moreMessages));
      }
    } catch (e, stackTrace) {
      _log.e('Error loading more messages', error: e, stackTrace: stackTrace);
      if (mounted) showAlertErrorDialog(context, error: e);
    } finally {
      _isLoadingMore = false;
    }
  }

  void _loadData() async {
    try {
      await _loadChatHistory();
      await _markAsRead();
      await _registerOnReceiveMessage();
      await _registerOnReadMessage();
    } catch (e, stackTrace) {
      _chatViewState.value = ChatViewState.error;
      _log.e('Error loading chat room', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _loadChatHistory() async {
    var roomId = roomData.id;
    final totalChunks = await _chatService.chunkCount(roomId: roomId);
    _chunk = totalChunks == 0 ? 1 : totalChunks;

    final initialMessage = await _chatService.messages(roomId: roomId, chunk: _chunk);
    _chatController.loadMoreData(_mapMessages(initialMessage));
    _chatViewState.value = initialMessage.isEmpty ? ChatViewState.noData : ChatViewState.hasMessages;
  }

  Future<void> _markAsRead() async {
    final otherMessages = _chatController.initialMessageList.reversed.where((element) => element.sentBy != profile.id.toString());
    final messagesIds = <String>[];
    for (var message in otherMessages) {
      if (message.status == MessageStatus.read) break;
      messagesIds.add(message.id);
    }

    if (messagesIds.isNotEmpty) {
      await _chatService.markAsRead(roomId: roomData.id, messagesIds: messagesIds);
    }
  }

  Future<void> _registerOnReceiveMessage() async {
    await _chatService.onReceiveMessageRoom(
      roomId: roomData.id,
      onReceiveMessage: (messageSent) {
        final message = messageSent.message;

        if (message.sentBy == profile.id && _messagesRequests.contains(messageSent.requestId)) {
          _messagesRequests.remove(messageSent.requestId);
          return;
        }

        _chatController.addMessage(_mapMessage(message));

        if (_chatViewState.value == ChatViewState.noData) {
          _chatViewState.value = ChatViewState.hasMessages;
        }
      },
    );
  }

  Future<void> _registerOnReadMessage() async {
    await _chatService.onReadMessageRoom(
      roomId: roomData.id,
      onReadMessage: (readMessages) {
        if (roomData.room.type == ChatRoomType.group) return;
        final messages = _chatController.initialMessageList;
        for (var message in messages) {
          if (readMessages.messageIds.contains(message.id)) {
            message.setStatus = MessageStatus.read;
          }
        }
      },
    );
  }

  void _sendMessage(String message, ReplyMessage replyMessage, MessageType messageType) async {
    //
    final meessageSent = Message(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      message: message,
      sentBy: _chatController.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
      status: MessageStatus.pending,
    );

    _chatController.addMessage(meessageSent);
    if (_chatViewState.value == ChatViewState.noData) {
      _chatViewState.value = ChatViewState.hasMessages;
    }

    try {
      _messagesRequests.add(meessageSent.id);
      await _chatService.send(roomId: roomData.id, requestId: meessageSent.id, message: message);
      meessageSent.setStatus = MessageStatus.delivered;
    } catch (e, stackTrace) {
      if (mounted) showAlertErrorDialog(context, error: e);
      _log.e('Error sending message', error: e, stackTrace: stackTrace);
      meessageSent.setStatus = MessageStatus.undelivered;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      showLeading: false,
      actionButton: SonaActionButton.home(),
      padding: 0,
      body: SonaChatView(
        chatController: _chatController,
        chatViewState: _chatViewState.value!,
        sendMessage: _sendMessage,
        enableCameraImagePicker: true,
        enableGalleryImagePicker: true,
        allowRecordingVoice: false,
      ),
    );
  }
}

Message _mapMessage(ChatMessage message) {
  return Message(
    id: message.id,
    message: message.message,
    sentBy: message.sentBy.toString(),
    createdAt: message.createdAt,
    status: MessageStatus.read,
  );
}

List<Message> _mapMessages(List<ChatMessage> messages) {
  return messages.map(_mapMessage).toList();
}

ChatUser _mapUser(User user) {
  return ChatUser(
    id: user.id.toString(),
    name: user.representation.firstName,
    profilePhoto: user.profilePicturePath,
  );
}

List<ChatUser> _mapUsers(List<User> users) {
  return users.map(_mapUser).toList();
}
