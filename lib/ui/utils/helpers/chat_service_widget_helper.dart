import 'package:flutter/foundation.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';


class ChatRoomUi extends ChatRoom {
  final ChatMessage? lastMessage;

  ChatRoomUi({
    required super.id,
    required super.name,
    required super.type,
    super.participants = const [],
    this.lastMessage,
  });

  ChatRoomUi copyWith({
    String? id,
    String? name,
    ChatRoomType? type,
    List<ChatUser>? participants,
    ChatMessage? lastMessage,
  }) {
    return ChatRoomUi(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

}

mixin ChatServiceWidgetHelper {
  ChatService get chatService;

  @protected
  Future<List<ChatRoomUi>> chatRoom() async {
    final rooms = await chatService.rooms();
    return await Future.wait(rooms.map((room) => _parseChatRoomUi(room)));
  }

  @protected
  Future<ChatRoomUi> chatRooms({
    String? roomId,
    int? userId,
  }) async {
    final room = await chatService.room(roomId: roomId, userId: userId);
    return await _parseChatRoomUi(room);
  }

  Future<ChatRoomUi> _parseChatRoomUi(ChatRoom room) async {
    final lastMessage = await chatService.lastMessage(roomId: room.id);
    return ChatRoomUi(
      id: room.id,
      name: room.name,
      type: room.type,
      participants: room.participants,
      lastMessage: lastMessage,
    );
  }
}

class ChatRoomsListenner extends ChangeNotifier implements ValueListenable<List<ChatRoomUi>> {
  //
  final Map<String, ChatRoomUi> _chatRoomsMap = {};

  List<ChatRoomUi> get _chatRooms => _chatRoomsMap.values.toList()
    ..sort((a, b) {
      final createdAtA = a.lastMessage?.createdAt;
      final createdAtB = b.lastMessage?.createdAt;
      if (createdAtA == null || createdAtB == null) return 0;
      return createdAtB.compareTo(createdAtA);
    });

  void addRooms(List<ChatRoomUi> rooms) {
    for (var room in rooms) {
      _chatRoomsMap[room.id] = room;
    }
    notifyListeners();
  }

  void addRoom(ChatRoomUi room) {
    if (!_chatRoomsMap.containsKey(room.id)) {
      _chatRoomsMap[room.id] = room;
      notifyListeners();
    }
  }

  void updateRoomLastMessage(String roomId, ChatMessage message) {
    if (_chatRoomsMap.containsKey(roomId)) {
      final updatedRoom = _chatRoomsMap[roomId]!.copyWith(lastMessage: message);
      _chatRoomsMap[roomId] = updatedRoom;
      _chatRoomsMap[roomId] = updatedRoom;
      notifyListeners();
    }
  }

  bool exists(String roomId) => _chatRoomsMap.containsKey(roomId);

  void clearRooms() {
    _chatRoomsMap.clear();
    notifyListeners();
  }

  @override
  List<ChatRoomUi> get value => _chatRooms;
}
