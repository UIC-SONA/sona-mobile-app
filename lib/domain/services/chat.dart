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

typedef OnReceiveMessage = void Function(ChatMessageSent message);
typedef OnReadMessage = void Function(ReadMessages messagesIds);

abstract class ChatService {
  //
  final List<OnReceiveMessage> _onReceiveMessageListeners = [];
  final List<OnReadMessage> _onReadMessageListeners = [];

  Future<void> init();

  Future<void> close();

  //
  Future<ChatMessageSent> send({
    required String roomId,
    required String requestId,
    required String message,
  });

  Future<ChatMessageSent> sendImage({
    required String roomId,
    required String requestId,
    required String imagePath,
  });

  Future<ChatMessageSent> sendVoice({
    required String roomId,
    required String requestId,
    required String audioPath,
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

mixin ChatMessageListenner<T extends ChatService> {
//
  @protected
  T get chatService;

  @protected
  String? get filterRoomId => null;

  OnReceiveMessage? registerOnReceiveMessage;
  OnReadMessage? registerOnReadMessage;

  bool _hasInit = false;

  @protected
  void initMessageListeners() {
    if (_hasInit) throw StateError('Listeners already initialized');
    _hasInit = true;
    if (filterRoomId == null) {
      registerOnReceiveMessage = onReceiveMessage;
      registerOnReadMessage = onReadMessage;
    } else {
      registerOnReceiveMessage = (messageSent) => messageSent.roomId == filterRoomId ? onReceiveMessage(messageSent) : null;
      registerOnReadMessage = (readMessages) => readMessages.roomId == filterRoomId ? onReadMessage(readMessages) : null;
    }

    chatService._addOnReceiveMessageListener(registerOnReceiveMessage!);
    chatService._addOnReadMessageListener(registerOnReadMessage!);
  }

  @protected
  void disposeMessageListeners() {
    if (registerOnReceiveMessage != null) chatService._removeOnReceiveMessageListener(registerOnReceiveMessage!);
    if (registerOnReadMessage != null) chatService._removeOnReadMessageListener(registerOnReadMessage!);
  }

  void onReceiveMessage(ChatMessageSent messageSent);

  void onReadMessage(ReadMessages readMessages);
}

Logger _log = Logger();

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
            _log.i('Read messages: $readMessages');
            for (final listener in _onReadMessageListeners) {
              listener(readMessages);
            }
          });
          _subscribeOnReceiveMessage(stompClient!, '/topic/chat.inbox.$userId', (messageSent) {
            _log.i('Received message: $messageSent');
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
  Future<ChatMessageSent> send({
    required String roomId,
    required String requestId,
    required String message,
  }) async {
    final response = await request(
      uri.replace(path: '$path/send/$roomId', queryParameters: {'requestId': requestId}),
      client: client,
      method: HttpMethod.post,
      headers: {
        'Content-Type': 'text/plain',
        ...commonHeaders,
      },
      body: message,
    );

    return response.getBody<ChatMessageSent>();
  }

  @override
  Future<ChatMessageSent> sendImage({
    required String roomId,
    required String requestId,
    required String imagePath,
  }) async {
    final response = await multipartRequest(
      uri.replace(path: '$path/send/$roomId/image', queryParameters: {'requestId': requestId}),
      method: HttpMethod.post,
      client: client,
      headers: commonHeaders,
      factory: (request) async {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      },
    );

    return response.getBody<ChatMessageSent>();
  }

  @override
  Future<ChatMessageSent> sendVoice({
    required String roomId,
    required String requestId,
    required String audioPath,
  }) async {
    final response = await multipartRequest(
      uri.replace(path: '$path/send/$roomId/voice', queryParameters: {'requestId': requestId}),
      method: HttpMethod.post,
      client: client,
      headers: commonHeaders,
      factory: (request) async {
        request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
      },
    );

    return response.getBody<ChatMessageSent>();
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
      uri.replace(path: '$path/room/$roomId/read', queryParameters: {'messagesIds': messagesIds.join(',')}),
      client: client,
      method: HttpMethod.put,
      headers: commonHeaders,
    );
  }
}

StompUnsubscribe _subscribeOnReceiveMessage(StompClient client, String destination, OnReceiveMessage onReceiveMessage) {
  _log.i('Subscribing to $destination');
  return client.subscribe(
    destination: destination,
    callback: (frame) {
      if (frame.body == null) return;
      onReceiveMessage(ChatMessageSent.fromJson(jsonDecode(frame.body!)));
    },
  );
}

StompUnsubscribe _subscribeOnReadMessage(StompClient client, String destination, OnReadMessage onReadMessage) {
  _log.i('Subscribing to $destination');
  return client.subscribe(
    destination: destination,
    callback: (frame) {
      if (frame.body == null) return;
      onReadMessage(ReadMessages.fromJson(jsonDecode(frame.body!)));
    },
  );
}
