import 'user.dart';

enum ChatMessageType {
  image,
  text,
  voice,
  custom;

  static ChatMessageType fromString(String value) {
    var type = value.trim().toLowerCase();
    for (var messageType in ChatMessageType.values) {
      if (messageType.name == type) {
        return messageType;
      }
    }
    throw ArgumentError('Invalid message type');
  }
}

enum ChatRoomType {
  private,
  group;

  static ChatRoomType fromString(String value) {
    var type = value.trim().toLowerCase();
    for (var roomType in ChatRoomType.values) {
      if (roomType.name == type) {
        return roomType;
      }
    }
    throw ArgumentError('Invalid room type');
  }
}

class ChatMessage {
  //
  final String id;

  final String message;

  final DateTime createdAt;

  final int sentBy;

  final ChatMessageType type;

  final Duration? voiceMessageDuration;

  final List<ReadBy> readBy;

  ChatMessage({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.sentBy,
    required this.type,
    required this.voiceMessageDuration,
    this.readBy = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      sentBy: json['sentBy'],
      type: ChatMessageType.fromString(json['type']),
      voiceMessageDuration: json['voiceMessageDuration'] != null ? Duration(milliseconds: json['voiceMessageDuration']) : null,
      readBy: (json['readBy'] as List<dynamic>? ?? []).map((e) => ReadBy.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'sentBy': sentBy,
      'type': type.toString(),
      'voiceMessageDuration': voiceMessageDuration?.inMilliseconds,
      'readBy': readBy.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ChatMessage{id: $id, message: $message, createdAt: $createdAt, sentBy: $sentBy, type: $type, voiceMessageDuration: $voiceMessageDuration';
  }
}

class ReadBy {
  final int participantId;
  final DateTime readAt;

  ReadBy({
    required this.participantId,
    required this.readAt,
  });

  factory ReadBy.fromJson(Map<String, dynamic> json) {
    return ReadBy(
      participantId: json['participantId'],
      readAt: DateTime.parse(json['readAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'readAt': readAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ReadBy{participantId: $participantId, readAt: $readAt}';
  }
}

class ChatRoom {
  final String id;

  final String name;

  final ChatRoomType type;

  final List<int> participants;

  ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.participants,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      type: ChatRoomType.fromString(json['type']),
      participants: List<int>.from(json['participants'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'participants': participants,
    };
  }
}

class ChatMessageSent {
  final ChatMessage message;
  final String roomId;
  final String requestId;

  ChatMessageSent({
    required this.message,
    required this.roomId,
    required this.requestId,
  });

  factory ChatMessageSent.fromJson(Map<String, dynamic> json) {
    return ChatMessageSent(
      message: ChatMessage.fromJson(json['message']),
      requestId: json['requestId'],
      roomId: json['roomId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
      'roomId': roomId,
      'requestId': requestId,
    };
  }

  @override
  String toString() {
    return 'ChatMessageSent{message: $message, requestId: $requestId, roomId: $roomId}';
  }
}

class ReadMessages {
  final String roomId;
  final ReadBy readBy;
  final List<String> messageIds;

  ReadMessages({
    required this.roomId,
    required this.readBy,
    required this.messageIds,
  });

  factory ReadMessages.fromJson(Map<String, dynamic> json) {
    return ReadMessages(
      roomId: json['roomId'],
      readBy: ReadBy.fromJson(json['readBy']),
      messageIds: List<String>.from(json['messageIds'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'readBy': readBy.toJson(),
      'messageIds': messageIds,
    };
  }

  @override
  String toString() {
    return 'ReadMessages{roomId: $roomId, readBy: $readBy, messageIds: $messageIds}';
  }
}

class ChatRoomData {
  final ChatRoom room;
  final List<User> participants;
  final ChatMessage? lastMessage;

  ChatRoomData({
    required this.room,
    required this.participants,
    required this.lastMessage,
  });

  String get id => room.id;

  @override
  String toString() {
    return 'ChatRoomInformation(room: $room, participants: $participants, lastMessage: $lastMessage)';
  }

  ChatRoomData copyWith({
    ChatRoom? room,
    List<User>? participants,
    ChatMessage? lastMessage,
  }) {
    return ChatRoomData(
      room: room ?? this.room,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
