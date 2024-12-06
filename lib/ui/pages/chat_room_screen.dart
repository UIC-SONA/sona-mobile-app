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
  final User owner;
  final Future<ChatRoom> Function() getRoom;

  const ChatRoomScreen({
    super.key,
    required this.owner,
    required this.getRoom,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

Logger _log = Logger();

class _ChatRoomScreenState extends FullState<ChatRoomScreen> {
  late final _userService = injector.get<UserService>();
  late final _chatService = injector.get<ChatService>();

  final List<String> _messagesSent = [];
  final ScrollController _scrollController = ScrollController();

  ChatRoom? _room;
  ChatController? _chatController;
  ChatViewState _chatViewState = ChatViewState.loading;
  int _chunk = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    if (_room != null) _chatService.unsubscribe(roomId: _room!.id);
    _scrollController.dispose();
    _chatController?.dispose();
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
      final previousChunk = _chunk - 1;

      final moreMessages = await _chatService.messages(
        roomId: _room!.id,
        chunk: previousChunk,
      );

      if (moreMessages.isNotEmpty) {
        _chunk = previousChunk;
        _chatController?.loadMoreData(_mapMessages(moreMessages));
      }
    } catch (e, stackTrace) {
      _log.e('Error loading more messages', error: e, stackTrace: stackTrace);
      if (mounted) showAlertErrorDialog(context, error: e);
    } finally {
      _isLoadingMore = false;
    }
  }

  void _load() async {
    try {
      _room = await widget.getRoom();
      _loadChatSubscription();
      await _loadChatHistory();
    } catch (e, stackTrace) {
      _chatViewState = ChatViewState.error;
      _log.e('Error loading chat', error: e, stackTrace: stackTrace);
      refresh();
    } finally {
      refresh();
    }
  }

  Future<void> _loadChatHistory() async {
    final users = (await _getUsers(_room!.participants)).where((user) => user.id != widget.owner.id).toList();

    var roomId = _room!.id;
    final totalChunks = await _chatService.chunkCount(roomId: roomId);
    _chunk = totalChunks == 0 ? 1 : totalChunks;

    final initialMessage = await _chatService.messages(roomId: roomId, chunk: _chunk);

    _chatController = ChatController(
      initialMessageList: _mapMessages(initialMessage),
      scrollController: _scrollController,
      otherUsers: _mapUsers(users),
      currentUser: _mapUser(widget.owner),
    );

    _chatViewState = initialMessage.isEmpty ? ChatViewState.noData : ChatViewState.hasMessages;
    refresh();
  }

  void _loadChatSubscription() {
    _chatService.subscribe(
      roomId: _room!.id,
      onMessage: (messageSent) {
        final message = messageSent.message;
        if (message.sentBy == widget.owner.id) {
          if (_messagesSent.any((requestId) => requestId == messageSent.requestId)) return;
        }
        if (_chatController != null) {
          _chatController!.addMessage(_mapMessage(message));
        }
      },
    );
  }

  Message _mapMessage(ChatMessage message) {
    final userId = message.sentBy;

    return Message(
      id: message.id,
      message: message.message,
      sentBy: userId.toString(),
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
      // profilePhoto: user.profilePicturePath,
    );
  }

  List<ChatUser> _mapUsers(List<User> users) {
    return users.map(_mapUser).toList();
  }

  Future<List<User>> _getUsers(List<int> userIds) async {
    return await Future.wait(userIds.map(_userService.find));
  }

  void _sendMessage(String message, ReplyMessage replyMessage, MessageType messageType) async {
    final meessageSent = Message(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      message: message,
      sentBy: _chatController!.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
      status: MessageStatus.pending,
    );

    _chatController!.addMessage(meessageSent);
    if (_chatViewState == ChatViewState.noData) {
      _chatViewState = ChatViewState.hasMessages;
      refresh();
    }

    try {
      _messagesSent.add(meessageSent.id);
      await _chatService.send(roomId: _room!.id, requestId: meessageSent.id, message: message);
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
}
