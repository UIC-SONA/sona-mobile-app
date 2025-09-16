enum ChatMessageType {
  image,
  text,
  voice,
  video,
  custom;

  bool get isImage => this == ChatMessageType.image;

  bool get isText => this == ChatMessageType.text;

  bool get isVoice => this == ChatMessageType.voice;

  bool get isVideo => this == ChatMessageType.video;

  bool get isCustom => this == ChatMessageType.custom;

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

class ChatUser {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final bool enabled;
  final String email;
  final bool hasProfilePicture;

  ChatUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.enabled,
    required this.email,
    required this.hasProfilePicture,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      enabled: json['enabled'],
      email: json['email'],
      hasProfilePicture: json['hasProfilePicture'],
    );
  }

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'enabled': enabled,
      'email': email,
      'hasProfilePicture': hasProfilePicture,
    };
  }
}

class ChatMessage {
  //
  final String id;
  final String message;
  final DateTime createdAt;
  final ChatUser sentBy;
  final ChatMessageType type;
  final Duration? voiceMessageDuration;
  final List<ChatReadBy> readBy;

  ChatMessage({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.sentBy,
    required this.type,
    required this.voiceMessageDuration,
    this.readBy = const []
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      sentBy: ChatUser.fromJson(json['sentBy']),
      type: ChatMessageType.fromString(json['type']),
      voiceMessageDuration: json['voiceMessageDuration'] != null ? Duration(milliseconds: json['voiceMessageDuration']) : null,
      readBy: (json['readBy'] as List<dynamic>? ?? []).map((e) => ChatReadBy.fromJson(e)).toList(),
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
      'readBy': readBy.map((e) => e.toJson()).toList()
    };
  }
}

class ChatReadBy {
  final ChatUser participant;
  final DateTime readAt;

  ChatReadBy({
    required this.participant,
    required this.readAt
  });

  factory ChatReadBy.fromJson(Map<String, dynamic> json) {
    return ChatReadBy(
        participant: ChatUser.fromJson(json['participant']),
        readAt: DateTime.parse(json['readAt'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant': participant.toJson(),
      'readAt': readAt.toIso8601String()
    };
  }
}

class ChatRoom {
  //
  final String id;
  final String name;
  final ChatRoomType type;
  final List<ChatUser> participants;

  ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    this.participants = const []
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
        id: json['id'],
        name: json['name'],
        type: ChatRoomType.fromString(json['type']),
        participants: (json['participants'] as List<dynamic>? ?? []).map((e) => ChatUser.fromJson(e)).toList()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'participants': participants.map((e) => e.toJson()).toList()
    };
  }
}

class ChatMessageDto {
  final ChatMessage message;
  final String roomId;
  final String requestId;

  ChatMessageDto({
    required this.message,
    required this.roomId,
    required this.requestId
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
        message: ChatMessage.fromJson(json['message']),
        requestId: json['requestId'],
        roomId: json['roomId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
      'roomId': roomId,
      'requestId': requestId
    };
  }
}

class ChatReadMessages {
  final String roomId;
  final ChatReadBy readBy;
  final List<String> messageIds;

  ChatReadMessages({
    required this.roomId,
    required this.readBy,
    required this.messageIds
  });

  factory ChatReadMessages.fromJson(Map<String, dynamic> json) {
    return ChatReadMessages(
        roomId: json['roomId'],
        readBy: ChatReadBy.fromJson(json['readBy']),
        messageIds: List<String>.from(json['messageIds'] as List<dynamic>)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'readBy': readBy.toJson(),
      'messageIds': messageIds
    };
  }
}
