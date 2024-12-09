import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';

typedef OnReceiveMessage = void Function(ChatMessageSent message);
typedef OnReadMessage = void Function(ReadMessages messagesIds);

abstract class ChatService {
  //
  Future<ChatMessageSent> send({
    required String roomId,
    required String requestId,
    required String message,
  });

  Future<ChatMessageSent> sendImage({
    required String roomId,
    required String requestId,
    required List<int> image,
    required String filename,
  });

  Future<ChatMessageSent> sendVoice({
    required String roomId,
    required String requestId,
    required List<int> voice,
    required String filename,
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

  Future<void> onReceiveMessageRoom({
    required String roomId,
    required OnReceiveMessage onReceiveMessage,
  });

  Future<void> closeOnReceiveMessageRoom({
    required String roomId,
  });

  Future<void> onReceiveMessageInbox({
    required User profile,
    required OnReceiveMessage onReceiveMessage,
  });

  Future<void> closeReceiveMessageInbox();

  Future<void> markAsRead({
    required String roomId,
    required List<String> messagesIds,
  });

  Future<void> onReadMessageRoom({
    required String roomId,
    required OnReadMessage onReadMessage,
  });

  Future<void> closeOnReadMessageRoom({
    required String roomId,
  });

  Future<void> onReadMessageInbox({
    required User profile,
    required OnReadMessage onReadMessage,
  });

  Future<void> closeOnReadMessageInbox();

  void close();

  void open();
}

Logger _log = Logger();

class ApiStompChatService implements ChatService, WebResource {
  final Map<String, StompUnsubscribe> _roomReceivesMessagesSubscriptions = {};
  final Map<String, StompUnsubscribe> _roomReadMessagesSubscriptions = {};

  StompUnsubscribe? _inboxReceiveMessagesSubscription;
  StompUnsubscribe? _inboxReadMessagesSubscription;

  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  final StompClient stompClient = StompClient(
    config: StompConfig(
      url: stompUri,
      onDisconnect: (frame) => _log.i('STOMP disconnected: ${frame.body}'),
      onStompError: (frame) => _log.e('STOMP error: ${frame.body}'),
      onWebSocketError: (error) => _log.e('WebSocket error: $error'),
    ),
  );

  ApiStompChatService({
    required this.authProvider,
    required this.localeProvider,
  });

  @override
  http.Client? get client => authProvider.client;

  @override
  Uri get uri => apiUri;

  @override
  Map<String, String> get commonHeaders => {'Accept-Language': localeProvider.languageCode};

  @override
  String get path => '/chat';

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
    required List<int> image,
    required String filename,
  }) async {
    final response = await multipartRequest(
      uri.replace(path: '$path/send/$roomId/image', queryParameters: {'requestId': requestId}),
      method: HttpMethod.post,
      client: client,
      headers: commonHeaders,
      factory: (request) async {
        request.files.add(http.MultipartFile.fromBytes('image', image, filename: filename));
      },
    );

    return response.getBody<ChatMessageSent>();
  }

  @override
  Future<ChatMessageSent> sendVoice({
    required String roomId,
    required String requestId,
    required List<int> voice,
    required String filename,
  }) async {
    final response = await multipartRequest(
      uri.replace(path: '$path/send/$roomId/voice', queryParameters: {'requestId': requestId}),
      method: HttpMethod.post,
      client: client,
      headers: commonHeaders,
      factory: (request) async {
        request.files.add(http.MultipartFile.fromBytes('voice', voice, filename: filename));
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
  Future<void> onReceiveMessageRoom({
    required String roomId,
    required OnReceiveMessage onReceiveMessage,
  }) async {
    stompClient.activate();

    if (_roomReceivesMessagesSubscriptions.containsKey(roomId)) return;
    final destination = '/topic/chat.room.$roomId';
    _roomReceivesMessagesSubscriptions[roomId] = _subscribeOnReceiveMessage(stompClient, destination, onReceiveMessage);
  }

  @override
  Future<void> closeOnReceiveMessageRoom({required String roomId}) async {
    final unsubscribeFn = _roomReceivesMessagesSubscriptions.remove(roomId);
    unsubscribeFn?.call();
  }

  @override
  Future<void> onReceiveMessageInbox({
    required User profile,
    required OnReceiveMessage onReceiveMessage,
  }) async {
    stompClient.activate();
    if (_inboxReceiveMessagesSubscription != null) return;
    final destination = '/topic/chat.inbox.${profile.id}';
    _inboxReceiveMessagesSubscription = _subscribeOnReceiveMessage(stompClient, destination, onReceiveMessage);
  }

  @override
  Future<void> closeReceiveMessageInbox() async {
    _inboxReceiveMessagesSubscription?.call();
    _inboxReceiveMessagesSubscription = null;
    _log.i('Unsubscribed from inbox');
  }

  @override
  Future<void> markAsRead({
    required String roomId,
    required List<String> messagesIds,
  }) async {
    await request(
      uri.replace(path: '$path/message/$messagesIds/read'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
  }

  @override
  Future<void> onReadMessageRoom({
    required String roomId,
    required OnReadMessage onReadMessage,
  }) async {
    stompClient.activate();

    if (_roomReadMessagesSubscriptions.containsKey(roomId)) return;
    final destination = '/topic/chat.room.$roomId.read';
    _roomReadMessagesSubscriptions[roomId] = _subscribeOnReadMessage(stompClient, destination, onReadMessage);
  }

  @override
  Future<void> closeOnReadMessageRoom({required String roomId}) async {
    final unsubscribeFn = _roomReadMessagesSubscriptions.remove(roomId);
    unsubscribeFn?.call();
  }

  @override
  Future<void> onReadMessageInbox({
    required User profile,
    required OnReadMessage onReadMessage,
  }) async {
    stompClient.activate();
    if (_inboxReadMessagesSubscription != null) return;
    final destination = '/topic/chat.inbox.${profile.id}.read';
    _inboxReadMessagesSubscription = _subscribeOnReadMessage(stompClient, destination, onReadMessage);
  }

  @override
  Future<void> closeOnReadMessageInbox() async {
    _inboxReadMessagesSubscription?.call();
    _inboxReadMessagesSubscription = null;
    _log.i('Unsubscribed from inbox');
  }

  @override
  void close() => stompClient.deactivate();

  @override
  void open() => stompClient.activate();
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
