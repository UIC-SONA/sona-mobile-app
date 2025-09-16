import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';

typedef OnReceiveMessage = void Function(ChatMessageDto message);
typedef OnReadMessage = void Function(ChatReadMessages messagesIds);

Logger _log = Logger();

abstract class ChatService {
  //
  final List<OnReceiveMessage> _onReceiveMessageListeners = [];
  final List<OnReadMessage> _onReadMessageListeners = [];

  Future<void> init();

  Future<void> close();

  //
  Future<ChatMessageDto> send({
    required ChatRoom room,
    required String requestId,
    required String message,
  });

  Future<ChatMessageDto> sendImage({
    required ChatRoom room,
    required String requestId,
    required String imagePath,
  });

  Future<ChatMessageDto> sendVoice({
    required ChatRoom room,
    required String requestId,
    required String audioPath,
  });

  Future<ChatMessageDto> sendVideo({
    required ChatRoom room,
    required String requestId,
    required String videoPath,
  });

  Future<List<ChatRoom>> rooms();

  Future<ChatRoom> room({
    String? roomId,
    int? userId,
  });

  Future<List<ChatMessage>> messages({
    required String roomId,
    required int chunk,
  });

  Future<ChatMessage?> lastMessage({
    required String roomId,
  });

  Future<int> chunkCount({
    required String roomId,
  });

  Future<void> markAsRead({
    required String roomId,
    required List<String> messagesIds,
  });

  void _addOnReceiveMessageListener(OnReceiveMessage listener) => _onReceiveMessageListeners.add(listener);

  void _addOnReadMessageListener(OnReadMessage listener) => _onReadMessageListeners.add(listener);

  void _removeOnReceiveMessageListener(OnReceiveMessage listener) => _onReceiveMessageListeners.remove(listener);

  void _removeOnReadMessageListener(OnReadMessage listener) => _onReadMessageListeners.remove(listener);
}

mixin ChatMessageListenner {
  //
  ChatService get chatService;

  String? get filterRoomId => null;

  OnReceiveMessage? onReceiveMessageCb;

  OnReadMessage? onReadMessageCb;

  bool _hasInit = false;

  @protected
  void initMessageListeners() {
    if (_hasInit) throw StateError('Listeners already initialized');
    _hasInit = true;
    if (filterRoomId == null) {
      onReceiveMessageCb = onReceiveMessage;
      onReadMessageCb = onReadMessage;
    } else {
      onReceiveMessageCb = (messageSent) {
        if (messageSent.roomId == filterRoomId) {
          onReceiveMessage(messageSent);
        }
      };
      onReadMessageCb = (readMessages) {
        if (readMessages.roomId == filterRoomId) {
          onReadMessage(readMessages);
        }
      };
    }

    chatService._addOnReceiveMessageListener(onReceiveMessageCb!);
    chatService._addOnReadMessageListener(onReadMessageCb!);
  }

  @protected
  void disposeMessageListeners() {
    if (onReceiveMessageCb != null) {
      chatService._removeOnReceiveMessageListener(onReceiveMessageCb!);
    }
    if (onReadMessageCb != null) {
      chatService._removeOnReadMessageListener(onReadMessageCb!);
    }
  }

  @protected
  void onReceiveMessage(ChatMessageDto messageSent);

  @protected
  void onReadMessage(ChatReadMessages readMessages);
//
}

class ApiStompChatService extends ChatService implements WebResource {
  //
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;
  final UserService userService;

  StompClient? stompClient;

  ApiStompChatService({
    required this.authProvider,
    required this.localeProvider,
    required this.userService,
  }) {
    init();
  }

  @override
  http.Client? get client => authProvider.client;

  @override
  Uri get uri => apiUri;

  @override
  Map<String, String> get commonHeaders => {'Accept-Language': localeProvider.languageCode};

  @override
  String get path => '/chat';

  @override
  Future<void> init() async {
    if (stompClient != null) close();
    if (!(await authProvider.isAuthenticated())) return;
    final userId = userService.currentUser.id;
    //
    stompClient = StompClient(
      config: StompConfig(
        url: stompUri,
        onDisconnect: (frame) => _log.i('STOMP disconnected: ${frame.body}'),
        onStompError: (frame) => _log.e('STOMP error: ${frame.body}'),
        onWebSocketError: (error) => _log.e('WebSocket error: $error'),
        onConnect: (frame) {
          _subscribeOnReadMessage(stompClient!, '/topic/chat.inbox.$userId.read', (readMessages) {
            for (final listener in _onReadMessageListeners) {
              listener(readMessages);
            }
          });
          _subscribeOnReceiveMessage(stompClient!, '/topic/chat.inbox.$userId', (messageSent) {
            for (final listener in _onReceiveMessageListeners) {
              listener(messageSent);
            }
          });
        },
      ),
    );

    stompClient!.activate();
  }

  @override
  Future<void> close() async {
    stompClient?.deactivate();
    stompClient = null;
  }

  @override
  Future<ChatMessageDto> send({
    required ChatRoom room,
    required String requestId,
    required String message,
  }) async {
    final response = await request(
      uri.replace(path: '$path/send/${room.id}', queryParameters: {'requestId': requestId}),
      client: client,
      method: HttpMethod.post,
      headers: {
        'Content-Type': 'text/plain',
        ...commonHeaders,
      },
      body: message,
    );

    return response.getBody<ChatMessageDto>();
  }

  @override
  Future<ChatMessageDto> sendImage({
    required ChatRoom room,
    required String requestId,
    required String imagePath,
  }) async {
    final response = await multipartRequest(
      uri.replace(path: '$path/send/${room.id}/image', queryParameters: {'requestId': requestId}),
      method: HttpMethod.post,
      client: client,
      headers: commonHeaders,
      factory: (request) async {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      },
    );

    return response.getBody<ChatMessageDto>();
  }

  @override
  Future<ChatMessageDto> sendVoice({
    required ChatRoom room,
    required String requestId,
    required String audioPath,
  }) async {
    final response = await multipartRequest(
      uri.replace(path: '$path/send/${room.id}/voice', queryParameters: {'requestId': requestId}),
      method: HttpMethod.post,
      client: client,
      headers: commonHeaders,
      factory: (request) async {
        request.files.add(await http.MultipartFile.fromPath('voice', audioPath));
      },
    );

    return response.getBody<ChatMessageDto>();
  }

  @override
  Future<ChatMessageDto> sendVideo({
    required ChatRoom room,
    required String requestId,
    required String videoPath,
  }) async {
    final response = await multipartRequest(
      uri.replace(path: '$path/send/${room.id}/video', queryParameters: {'requestId': requestId}),
      method: HttpMethod.post,
      client: client,
      headers: commonHeaders,
      factory: (request) async {
        request.files.add(await http.MultipartFile.fromPath('video', videoPath));
      },
    );

    return response.getBody<ChatMessageDto>();
  }

  @override
  Future<ChatRoom> room({
    String? roomId,
    int? userId,
  }) async {
    if (roomId == null && userId == null) throw ArgumentError('Either roomId or userId must be provided');
    if (roomId != null && userId != null) throw ArgumentError('Only one of roomId or userId must be provided');

    final response = await request(
      uri.replace(path: '$path${roomId != null ? '/room/$roomId' : '/user/$userId/room'}'),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.getBody<ChatRoom>();
  }

  @override
  Future<List<ChatRoom>> rooms() async {
    final response = await request(
      uri.replace(path: '$path/rooms'),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.getBody<List<ChatRoom>>();
  }

  @override
  Future<List<ChatMessage>> messages({
    required String roomId,
    required int chunk,
  }) async {
    final response = await request(
      uri.replace(path: '$path/room/$roomId/messages', queryParameters: {'chunk': chunk.toString()}),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.getBody<List<ChatMessage>>();
  }

  @override
  Future<ChatMessage?> lastMessage({
    required String roomId,
  }) async {
    final response = await request(
      uri.replace(path: '$path/room/$roomId/last-message'),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    if (response.body.isEmpty) return null;
    return response.getBody<ChatMessage>();
  }

  @override
  Future<int> chunkCount({
    required String roomId,
  }) async {
    final response = await request(
      uri.replace(path: '$path/room/$roomId/chunk-count'),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return int.parse(response.body);
  }

  @override
  Future<void> markAsRead({
    required String roomId,
    required List<String> messagesIds,
  }) async {
    await request(
      uri.replace(path: '$path/room/$roomId/read'),
      client: client,
      method: HttpMethod.put,
      headers: {
        ...commonHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(messagesIds),
    );
  }
}

StompUnsubscribe _subscribeOnReceiveMessage(StompClient client, String destination, OnReceiveMessage onReceiveMessage) {
  _log.i('Subscribing to $destination');
  return client.subscribe(
    destination: destination,
    callback: (frame) {
      if (frame.body == null) return;
      onReceiveMessage(ChatMessageDto.fromJson(jsonDecode(frame.body!)));
    },
  );
}

StompUnsubscribe _subscribeOnReadMessage(StompClient client, String destination, OnReadMessage onReadMessage) {
  _log.i('Subscribing to $destination');
  return client.subscribe(
    destination: destination,
    callback: (frame) {
      if (frame.body == null) return;
      onReadMessage(ChatReadMessages.fromJson(jsonDecode(frame.body!)));
    },
  );
}
