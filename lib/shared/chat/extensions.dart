import 'package:chatview/chatview.dart';

extension ChatControllerExtension on ChatController {
  void updateMessage(String messageId, Message newMessage) {
    final index = initialMessageList.indexWhere((message) => message.id == messageId);
    if (index != -1) {
      initialMessageList[index] = newMessage;
      if (messageStreamController.isClosed) return;
      messageStreamController.sink.add(initialMessageList);
    }
  }
}


extension MessageExtension on Message {

  Message copyWithCustom(String customType, [Map<String, dynamic>? update]) {
    return copyWith(
      messageType: MessageType.custom,
      update: {
        "customType": customType,
        ...?update,
      },
    );
  }

}