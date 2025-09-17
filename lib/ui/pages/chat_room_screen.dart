import 'dart:io';

import 'package:auto_route/annotations.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logger/logger.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart' hide ChatUser;
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/chat/extensions.dart';
import 'package:sona/ui/theme/colors.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/utils/helpers/chat_service_widget_helper.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_chat_view.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';
import 'package:uuid/uuid.dart';


@RoutePage()
class ChatRoomScreen extends StatefulWidget {
  final ChatRoomUi chatRoom;

  const ChatRoomScreen({
    super.key,
    required this.chatRoom,
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

  final List<String> messagesSended = [];

  late final chatController = ChatController(
    initialMessageList: [],
    scrollController: ScrollController(),
    otherUsers: chatRoom.participants.map((user) => ChatUser(
      id: user.id.toString(),
      name: user.firstName,
      profilePhoto: user.hasProfilePicture ? userService.profilePictureUrl(user.id) : null,
    )).toList(),
    currentUser: ChatUser(
      id: profile.id.toString(),
      name: profile.firstName,
      profilePhoto: profile.hasProfilePicture ? userService.profilePictureUrl(profile.id) : null,
    ),
  );

  var chatViewState = ChatViewState.loading;
  var chatChunk = 1;

  ChatRoomUi get chatRoom => widget.chatRoom;

  User get profile => userService.currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
    initMessageListeners();
  }

  @override
  void dispose() {
    disposeMessageListeners();
    super.dispose();
  }


  Future<void> _loadMoreMessages() async {
    if (chatChunk <= 1) return;
    try {
      final nextChunk = chatChunk - 1;
      final moreMessages = await chatService.messages(
        roomId: chatRoom.id,
        chunk: nextChunk,
      );
      if (moreMessages.isNotEmpty) {
        chatChunk = nextChunk;
        chatController.loadMoreData(_toMessages(moreMessages));
      }
    } catch (e, stackTrace) {
      _log.e('Error loading more messages', error: e, stackTrace: stackTrace);
      if (mounted) showAlertErrorDialog(context, error: e);
    }
  }

  void _loadData() async {
    try {
      await _loadChatHistory();
      await _markAsRead();
    } catch (e, stackTrace) {
      setState(() {
        chatViewState = ChatViewState.error;
      });
      _log.e('Error loading chat room', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _loadChatHistory() async {
    var roomId = chatRoom.id;
    final totalChunks = await chatService.chunkCount(roomId: roomId);
    chatChunk = totalChunks == 0 ? 1 : totalChunks;

    final initialMessage = await chatService.messages(roomId: roomId, chunk: chatChunk);
    chatController.loadMoreData(_toMessages(initialMessage));
    setState(() {
      chatChunk--;
      chatViewState = initialMessage.isEmpty ? ChatViewState.noData : ChatViewState.hasMessages;
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
      await chatService.markAsRead(roomId: chatRoom.id, messagesIds: messagesIds);
    }
  }

  @override
  void onReadMessage(ChatReadMessages readMessages) {
    if (chatRoom.type == ChatRoomType.group) return;
    var set = readMessages.messageIds.toSet();
    final messages = chatController.initialMessageList;
    for (var message in messages) {
      if (set.contains(message.id)) {
        message.setStatus = MessageStatus.read;
      }
    }
  }

  @override
  void onReceiveMessage(ChatMessageDto messageSent) {
    if (!mounted) return;
    _log.i('New message received: ${messageSent.message.id}');
    final message = messageSent.message;

    if (message.sentBy.id == profile.id && messagesSended.contains(messageSent.requestId)) {
      messagesSended.remove(messageSent.requestId);
      return;
    }

    chatController.addMessage(_toMessage(message));
    _updateChatViewStatus();

    if (message.sentBy.id != profile.id) {
      chatService.markAsRead(roomId: chatRoom.id, messagesIds: [message.id]);
    }
  }


  void _sendMessage(String message, ReplyMessage replyMessage, MessageType messageType, {String? customType}) async {

    final localMessageId = const Uuid().v4();

    final newMessage = Message(
      id: localMessageId,
      createdAt: DateTime.now(),
      message: message,
      sentBy: chatController.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
      status: MessageStatus.pending,
      update: customType != null ? {
        "customType": customType,
        if (messageType == MessageType.custom && customType == "video") 'src': message,
      } : null,
    );


    chatController.addMessage(newMessage);
    _updateChatViewStatus();

    try {
      messagesSended.add(localMessageId);

      final response = await switch (messageType) {
        MessageType.text => chatService.send(room: chatRoom, message: message, requestId: localMessageId),
        MessageType.image => chatService.sendImage(room: chatRoom, imagePath: message, requestId: localMessageId),
        MessageType.voice => chatService.sendVoice(room: chatRoom, audioPath: message, requestId: localMessageId),
        MessageType.custom => () {
         if (customType == "video") return chatService.sendVideo(room: chatRoom, videoPath: message, requestId: localMessageId);
          throw Exception('Unsupported custom message type: $customType');
        }()
      };

      chatController.updateMessage(localMessageId, newMessage.copyWith(
        id: response.message.id,
        createdAt: response.message.createdAt,
        status: MessageStatus.delivered,
      ));

    } catch (e) {
      _log.e('Error sending message', error: e);

      if (mounted) showAlertErrorDialog(context, error: e);
      chatController.updateMessage(localMessageId, newMessage.copyWith(
        status: MessageStatus.undelivered,
      ));
    }
  }

  void _updateChatViewStatus() {
    if (chatViewState == ChatViewState.noData && chatController.initialMessageList.isNotEmpty) {
      setState(() {
        chatViewState = ChatViewState.hasMessages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      bgGradient: bgGradientBackProfesional,
      showLeading: false,
      hideBgLogo: true,
      actionButton: SonaActionButton.home(),
      padding: 0,
      body: SonaChatView(
        chatController: chatController,
        chatViewState: chatViewState,
        sendMessage: _sendMessage,
        loadMoreData: _loadMoreMessages,
        enableCameraPicker: true,
        enableGalleryPicker: true,
        allowRecordingVoice: true,
        customMessageBuilder: _customMessageBuilder,
      ),
    );
  }

  Widget _customMessageBuilder(Message message) {
    final customType = message.update?['customType'] as String?;

    return switch (customType) {
      'voice_preview' => _buildVoicePreviewMessage(message),
      'video_preview' => _buildVideoPreviewMessage(message),
      'video' => _buildVideoMessage(message),
      'loading' => _buildLoadingMessage(),
      'error' => _buildErrorMessage(() {
        final src = message.update?['src'] as String?;
        final originalType = message.update?['originalType'] as String?;
        if (src == null || originalType == null) return;
        if (originalType == "voice_preview") {
          _downloadVoice(message);
        } else if (originalType == "video_preview") {
          _downloadVideo(message);
        }
      }),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildVideoMessage(Message message) {
    final src = message.update?['src'] as String?;
    if (src == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => OpenFilex.open(src),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Video descargado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toca para reproducir',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _downloadMedia(Message message, {
    required Function(File file) onDownloaded,
    required Function() onError
  }) async {
    final src = message.update?['src'] as String?;
    if (src == null) return;

    try {
      final loadingMessage = message.copyWithCustom("loading");
      chatController.updateMessage(message.id, loadingMessage);

      final file = await DefaultCacheManager().getSingleFile(src, key: message.id);
      onDownloaded(file);

    } catch (error) {
      _log.e('Error loading resource', error: error);
      onError();
    }
  }


  Future<void> _loadFromCache(String src, {
    required Function(File file) onLoaded,
    required Function() onMissing,
    Function()? onError
  }) async {
    try {
      final cacheFile = await DefaultCacheManager().getFileFromCache(src);

      if (cacheFile != null && await cacheFile.file.exists()) {
        // Ya está en caché, usar directamente
        onLoaded(cacheFile.file);
      } else {
        onMissing();
      }
    } catch (error) {
      _log.e('Error loading from cache', error: error);
      if (onError != null) onError();
    }
  }

  Future<void> _downloadVoice(Message message) async {
    _downloadMedia(message,
        onDownloaded: (file) {
          chatController.updateMessage(message.id, message.copyWith(
            message: file.path,
            messageType: MessageType.voice,
            update: null,
          ));
        },
        onError: () {
          final src = message.update?['src'] as String?;
          if (src == null) return;
          final errorMessage = message.copyWithCustom("error", {
            'src': src,
            "originalType": "voice_preview",
          });
          chatController.updateMessage(message.id, errorMessage);
        }
    );
  }

  Future<void> _downloadVideo(Message message) async {
    _downloadMedia(message,
        onDownloaded: (file) {
          chatController.updateMessage(message.id, message.copyWith(
            message: file.path,
            messageType: MessageType.custom,
            update: {
              "customType": "video",
              'src': file.path,
            },
          ));
        },
        onError: () {
          final src = message.update?['src'] as String?;
          if (src == null) return;
          final errorMessage = message.copyWithCustom("error", {
            'src': src,
            "originalType": "video_preview",
          });
          chatController.updateMessage(message.id, errorMessage);
        }
    );
  }



  Widget _buildVoicePreviewMessage(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _downloadVoice(message),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mic_rounded,
                  size: 18,
                  color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mensaje de voz',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreviewMessage(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _downloadVideo(message),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: 18,
                  color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  'Video',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Cargando...',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(GestureTapCallback? onRetry) {
    final errorColor = Theme.of(context).colorScheme.error;
    final errorColorOpacity = errorColor.withValues(alpha: 0.7);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorColorOpacity,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: errorColorOpacity,
            ),
            const SizedBox(width: 12),
            Text(
              'Error al descargar',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: errorColorOpacity,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: errorColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Message _toMessage(ChatMessage chatMessage) {
    final type = chatMessage.type;

    final status = solveMessageStatus(chatRoom, chatMessage, profile.id);

    // Crear mensaje base
    final baseMessage = Message(
      id: chatMessage.id,
      message: chatMessage.message,
      sentBy: chatMessage.sentBy.id.toString(),
      createdAt: chatMessage.createdAt,
      status: status,
      messageType: switch (type) {
        ChatMessageType.image => MessageType.image,
        ChatMessageType.text => MessageType.text,
        ChatMessageType.voice => MessageType.voice,
        _ => MessageType.custom,
      },
    );

    if (type.isVideo) {
      _loadFromCache(baseMessage.id,
          onLoaded: (file) {
            final cachedMessage = baseMessage.copyWithCustom("video", {
              'src': file.path,
            });
            chatController.updateMessage(chatMessage.id, cachedMessage);
          },
          onMissing: () {
            var videoPreviewMessage= baseMessage.copyWithCustom("video_preview", {
              'src': chatMessage.message,
            });
            chatController.updateMessage(chatMessage.id, videoPreviewMessage);
          }
      );
      return baseMessage.copyWithCustom("loading");
    }

    if (type.isVoice) {
      _loadFromCache(baseMessage.id,
          onLoaded: (file) {
            final cachedMessage = baseMessage.copyWith(
              message: file.path,
              messageType: MessageType.voice,
            );
            chatController.updateMessage(chatMessage.id, cachedMessage);
          },
          onMissing: () {
            final voicePrenviewMessage= baseMessage.copyWithCustom("voice_preview", {
              'src': chatMessage.message,
            });
            chatController.updateMessage(chatMessage.id, voicePrenviewMessage);
          }
      );

      return baseMessage.copyWithCustom("loading");
    }

    if (type.isImage) {
      return baseMessage.copyWith(message: chatMessage.message);
    }

    return baseMessage;
  }

  List<Message> _toMessages(List<ChatMessage> messages) {
    return messages.map(_toMessage).toList();
  }
}

MessageStatus solveMessageStatus(ChatRoom room, ChatMessage message, int userId) {
  //obtenmos los ids de los participantes excluyendo al usuario actual
  final participants = room.participants.where((participant) => participant.id != userId).toList();

  // Si aalguno de los participantes no ha leído el mensaje, está entregado
  if (message.readBy.length != participants.length) {
    return MessageStatus.delivered;
  }

  // Si todos los participantes han leído el mensaje, está leído
  if (message.readBy.every((readBy) => participants.any((p) => p.id == readBy.participant.id))) {
    return MessageStatus.read;
  }
  return MessageStatus.delivered;
}
