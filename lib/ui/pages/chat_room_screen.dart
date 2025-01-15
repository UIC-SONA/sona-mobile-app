import 'package:auto_route/annotations.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/utils/helpers/chat_service_widget_helper.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_chat_view.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class ChatRoomScreen extends StatefulWidget {
  final ChatRoomData roomData;

  const ChatRoomScreen({
    super.key,
    required this.roomData,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

final _log = Logger();

class _ChatRoomScreenState extends FullState<ChatRoomScreen> with ChatMessageListenner {
  //
  final userService = injector.get<UserService>();
  @override
  final chatService = injector.get<ChatService>();

  final ScrollController scrollController = ScrollController();
  final List<String> messagesSended = [];

  late final chatController = ChatController(
    initialMessageList: [],
    scrollController: scrollController,
    otherUsers: _mapUsers(roomData.participants),
    currentUser: _mapUser(profile),
  );

  var _chatViewState = ChatViewState.loading;
  var _chunk = 1;
  var _isLoadingMore = false;

  ChatRoomData get roomData => widget.roomData;

  User get profile => userService.currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
    initMessageListeners();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    disposeMessageListeners();
    super.dispose();
  }

  void _scrollListener() async {
    if (_isLoadingMore) return;
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      await _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_chunk <= 1) return;

    try {
      _isLoadingMore = true;
      final nextChunk = _chunk - 1;

      final moreMessages = await chatService.messages(
        roomId: roomData.id,
        chunk: nextChunk,
      );

      if (moreMessages.isNotEmpty) {
        _chunk = nextChunk;
        chatController.loadMoreData(_mapMessages(moreMessages));
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
    } catch (e, stackTrace) {
      setState(() {
        _chatViewState = ChatViewState.error;
      });
      _log.e('Error loading chat room', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _loadChatHistory() async {
    var roomId = roomData.id;
    final totalChunks = await chatService.chunkCount(roomId: roomId);
    _chunk = totalChunks == 0 ? 1 : totalChunks;

    final initialMessage = await chatService.messages(roomId: roomId, chunk: _chunk);
    chatController.loadMoreData(_mapMessages(initialMessage));
    setState(() {
      _chunk--;
      _chatViewState = initialMessage.isEmpty ? ChatViewState.noData : ChatViewState.hasMessages;
    });
  }

  Future<void> _markAsRead() async {
    var profileId = profile.id.toString();
    final otherMessages = chatController.initialMessageList.reversed.where((element) => element.sentBy != profileId);

    final messagesIds = <String>[];
    for (var message in otherMessages) {
      if (message.status == MessageStatus.read) break;
      messagesIds.add(message.id);
    }
    if (messagesIds.isNotEmpty) {
      await chatService.markAsRead(roomId: roomData.id, messagesIds: messagesIds);
    }
  }

  @override
  void onReadMessage(ReadMessages readMessages) {
    if (roomData.room.type == ChatRoomType.group) return;
    var set = readMessages.messageIds.toSet();
    final messages = chatController.initialMessageList;
    for (var message in messages) {
      if (set.contains(message.id)) {
        message.setStatus = MessageStatus.read;
      }
    }
  }

  @override
  void onReceiveMessage(ChatMessageSent messageSent) {
    if (!mounted) return;
    final message = messageSent.message;

    if (message.sentBy == profile.id && messagesSended.contains(messageSent.requestId)) {
      messagesSended.remove(messageSent.requestId);
      return;
    }

    chatController.addMessage(_mapMessage(message));
    _setChatViewStateHasMessages();

    if (message.sentBy != profile.id) {
      chatService.markAsRead(roomId: roomData.id, messagesIds: [message.id]);
    }
  }

  void _sendMessage(String message, ReplyMessage replyMessage, MessageType messageType) async {
    final requestId = const Uuid().v4();
    final newMessage = ExtededMessage(
      id: requestId,
      createdAt: DateTime.now(),
      message: message,
      sentBy: chatController.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
      status: MessageStatus.pending,
    );
    chatController.addMessage(newMessage);
    _setChatViewStateHasMessages();

    try {
      messagesSended.add(requestId);
      final messageSent = await switch (messageType) {
        MessageType.text => chatService.send(room: roomData.room, message: message, requestId: requestId),
        MessageType.image => chatService.sendImage(room: roomData.room, imagePath: message, requestId: requestId),
        MessageType.voice => chatService.sendVoice(room: roomData.room, audioPath: message, requestId: requestId),
        MessageType.custom => throw UnimplementedError(),
      };

      newMessage.forceId = messageSent.message.id;
      newMessage.setStatus = MessageStatus.delivered;
    } catch (e) {
      if (mounted) showAlertErrorDialog(context, error: e);
      newMessage.setStatus = MessageStatus.undelivered;
    }
  }

  void _setChatViewStateHasMessages() {
    if (_chatViewState == ChatViewState.noData) {
      _chatViewState = ChatViewState.hasMessages;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      showLeading: false,
      actionButton: SonaActionButton.home(),
      padding: 0,
      body: SonaChatView(
        chatController: chatController,
        chatViewState: _chatViewState,
        sendMessage: _sendMessage,
        enableCameraImagePicker: true,
        enableGalleryImagePicker: true,
        allowRecordingVoice: false,
      ),
    );
  }

  Message _mapMessage(ChatMessage message) {
    return Message(
      id: message.id,
      message: message.message,
      sentBy: message.sentBy.toString(),
      createdAt: message.createdAt,
      status: solveMessageStatus(roomData.room, message, profile.id),
    );
  }

  List<Message> _mapMessages(List<ChatMessage> messages) {
    return messages.map(_mapMessage).toList();
  }

  ChatUser _mapUser(User user) {
    return ChatUser(
      id: user.id.toString(),
      name: user.firstName,
      profilePhoto: user.hasProfilePicture ? userService.profilePictureUrl(user.id) : null,
    );
  }

  List<ChatUser> _mapUsers(List<User> users) {
    return users.map(_mapUser).toList();
  }
}

class ExtededMessage extends Message {
  final Map<String, dynamic> attributes;
  String? forceId;

  @override
  String get id => forceId ?? super.id;

  ExtededMessage({
    super.id = '',
    this.attributes = const {},
    required super.message,
    required super.createdAt,
    required super.sentBy,
    super.replyMessage = const ReplyMessage(),
    Reaction? reaction,
    super.messageType = MessageType.text,
    super.voiceMessageDuration,
    MessageStatus status = MessageStatus.pending,
  });
}

MessageStatus solveMessageStatus(ChatRoom room, ChatMessage message, int userId) {
  final participants = room.participants.where((participant) => participant != userId).toList();
  final readBy = message.readBy.map((readBy) => readBy.participantId).toSet();
  if (readBy.length != participants.length) return MessageStatus.delivered;
  if (readBy.containsAll(participants)) return MessageStatus.read;
  return MessageStatus.delivered;
}
