import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';

final _log = Logger();

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

mixin ChatServiceWidgetHelper on UserServiceWidgetHelper {
  ChatService get chatService;

  @protected
  Future<List<ChatRoomData>> roomsData() async {
    final rooms = await chatService.rooms();

    final usersIds = rooms.expand((room) => room.participants).toSet().where((userId) => userId != currentUser.id).toList();

    final participants = await findUsers(usersIds);
    if (participants.length != usersIds.length) {
      _log.w("Not all users were found");
    }

    return await Future.wait(rooms.map((room) => _createRoomData(room, participants)));
  }

  @protected
  Future<ChatRoomData> roomData({
    String? roomId,
    int? userId,
  }) async {
    final room = await chatService.room(roomId: roomId, userId: userId);
    final participants = await findUsers(room.participants);
    return await _createRoomData(room, participants);
  }

  Future<ChatRoomData> _createRoomData(ChatRoom room, [List<User>? participantsExistents]) async {
    //
    final participants = <User>[];
    for (final userId in room.participants) {
      if (userId == currentUser.id) continue;
      if (participantsExistents == null) {
        final participant = participantsExistents!.where((user) => user.id == userId).firstOrNull;
        if (participant != null) {
          participants.add(participant);
        } else {
          participants.add(UserService.notFound);
        }
      } else {
        final participant = await findUser(userId);
        participants.add(participant);
      }
    }

    final lastMessage = await chatService.lastMessage(roomId: room.id);
    return ChatRoomData(
      room: room,
      participants: participants,
      lastMessage: lastMessage,
    );
  }
}

class ChatRoomDataListenner extends ChangeNotifier implements ValueListenable<List<ChatRoomData>> {
  //
  final Map<String, ChatRoomData> _roomsDataMap = {};

  List<ChatRoomData> get _roomsData => _roomsDataMap.values.toList()
    ..sort((a, b) {
      final createdAtA = a.lastMessage?.createdAt;
      final createdAtB = b.lastMessage?.createdAt;
      if (createdAtA == null || createdAtB == null) return 0;
      return createdAtB.compareTo(createdAtA);
    });

  void addRooms(List<ChatRoomData> rooms) {
    for (var room in rooms) {
      _roomsDataMap[room.id] = room;
    }
    notifyListeners();
  }

  void addRoom(ChatRoomData room) {
    if (!_roomsDataMap.containsKey(room.id)) {
      _roomsDataMap[room.id] = room;
      notifyListeners();
    }
  }

  void updateRoomLastMessage(String roomId, ChatMessage message) {
    if (_roomsDataMap.containsKey(roomId)) {
      final updatedRoom = _roomsDataMap[roomId]!.copyWith(lastMessage: message);
      _roomsDataMap[roomId] = updatedRoom;
      notifyListeners();
    }
  }

  bool exists(String roomId) => _roomsDataMap.containsKey(roomId);

  void clearRooms() {
    _roomsDataMap.clear();
    notifyListeners();
  }

  @override
  List<ChatRoomData> get value => _roomsData;
}
