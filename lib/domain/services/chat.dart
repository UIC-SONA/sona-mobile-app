import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:sona/domain/models/chat.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';

typedef OnReceiveMessage = void Function(ChatMessageSent message);

abstract class ChatService {
  //
  Future<ChatMessageSent> send({required String roomId, required String requestId, required String message});

  Future<List<ChatRoom>> rooms();

  Future<ChatRoom> room({String? roomId, int? userId});

  Future<List<ChatMessage>> messages({required String roomId, required int chunk});

  Future<int> chunkCount({required String roomId});

  void subscribe({required String roomId, required OnReceiveMessage onMessage});

  void unsubscribe({required String roomId});

  void deactivate();

  void activate();
}

Logger _log = Logger();

class ApiStompChatService implements ChatService, WebResource {
  final Map<String, StompUnsubscribe> _subscriptions = {};

  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  final StompClient stompClient = StompClient(
    config: StompConfig(
      url: stompUri,
      beforeConnect: () async {
        _log.i('Connecting to STOMP...');
      },
      onConnect: (stompFrame) {
        _log.i('Connected to STOMP: ${stompFrame.body}');
      },
      onStompError: (frame) {
        _log.e('STOMP error: ${frame.body}');
      },
      onWebSocketError: (error) {
        _log.e('WebSocket error: $error');
      },
    ),
  );

  ApiStompChatService({required this.authProvider, required this.localeProvider});

  @override
  http.Client? get client => authProvider.client;

  @override
  Uri get uri => apiUri;

  @override
  Map<String, String> get headers => {'Accept-Language': localeProvider.languageCode};

  @override
  String get path => '/chat';


  @override
  Future<ChatMessageSent> send({required String roomId, required String requestId, required String message}) async {
    final response = await request(
      uri.replace(path: '$path/send/$roomId', queryParameters: {'requestId': requestId}),
      client: client,
      method: HttpMethod.post,
      headers: {
        'Content-Type': 'text/plain',
        ...headers,
      },
      body: message,
    );

    return response.getBody<ChatMessageSent>();
  }


  @override
  Future<ChatRoom> room({String? roomId, int? userId}) async {
    if (roomId == null && userId == null) throw ArgumentError('Either roomId or userId must be provided');
    if (roomId != null && userId != null) throw ArgumentError('Only one of roomId or userId must be provided');

    final response = await request(
      uri.replace(path: '$path${roomId != null ? '/rooms/$roomId' : '/user/$userId/room'}'),
      client: client,
      method: HttpMethod.get,
      headers: headers,
    );

    return response.getBody<ChatRoom>();
  }

  @override
  Future<List<ChatRoom>> rooms() async {
    final response = await request(
      uri.replace(path: '$path/rooms'),
      client: client,
      method: HttpMethod.get,
      headers: headers,
    );

    return response.getBody<List<ChatRoom>>();
  }


  @override
  Future<List<ChatMessage>> messages({required String roomId, required int chunk}) async {
    final response = await request(
      uri.replace(path: '$path/room/$roomId/messages', queryParameters: {'chunk': chunk.toString()}),
      client: client,
      method: HttpMethod.get,
      headers: headers,
    );

    return response.getBody<List<ChatMessage>>();
  }

  @override
  Future<int> chunkCount({required String roomId}) async {
    final response = await request(
      uri.replace(path: '$path/room/$roomId/chunk-count'),
      client: client,
      method: HttpMethod.get,
      headers: headers,
    );

    return response.getBody<int>();
  }

  @override
  void subscribe({required String roomId, required OnReceiveMessage onMessage}) {
    stompClient.activate();

    if (_subscriptions.containsKey(roomId)) return;
    final destination = '/topic/chat.room.$roomId';
    _log.i('Subscribing to $destination');

    final unsuscribeFn = stompClient.subscribe(
      destination: destination,
      callback: (frame) {
        _log.i('Message received: ${frame.body}');
        if (frame.body == null) return;
        onMessage(ChatMessageSent.fromJson(jsonDecode(frame.body!)));
      },
    );
    _subscriptions[roomId] = unsuscribeFn;
  }

  @override
  void unsubscribe({required String roomId}) {
    final unsubscribeFn = _subscriptions.remove(roomId);
    unsubscribeFn?.call();
  }

  @override
  void deactivate() {
    stompClient.deactivate();
  }

  @override
  void activate() {
    stompClient.activate();
  }
}
