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

  final int? chatRoomId;

  ChatMessage({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.sentBy,
    required this.type,
    required this.voiceMessageDuration,
    required this.chatRoomId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      sentBy: json['sentBy'],
      type: ChatMessageType.fromString(json['type']),
      voiceMessageDuration: json['voiceMessageDuration'] != null ? Duration(milliseconds: json['voiceMessageDuration']) : null,
      chatRoomId: json['chatRoomId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'sentBy': sentBy,
        'type': type.toString(),
        'voiceMessageDuration': voiceMessageDuration?.inMilliseconds,
        'chatRoomId': chatRoomId,
      };
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

  ChatRoom.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        type = ChatRoomType.fromString(json['type']),
        participants = List<int>.from(json['participants'] as List<dynamic>);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toString(),
        'participants': participants,
      };
}

class ChatMessageSent {
  final ChatMessage message;
  final String requestId;
  final String roomId;

  ChatMessageSent({
    required this.message,
    required this.requestId,
    required this.roomId,
  });

  ChatMessageSent.fromJson(Map<String, dynamic> json)
      : message = ChatMessage.fromJson(json['message'] as Map<String, dynamic>),
        requestId = json['requestId'],
        roomId = json['roomId'];

  Map<String, dynamic> toJson() => {
        'message': message.toJson(),
        'requestId': requestId,
        'roomId': roomId,
      };

  @override
  String toString() {
    return 'ChatMessageSent{message: $message, requestId: $requestId, roomId: $roomId}';
  }
}
