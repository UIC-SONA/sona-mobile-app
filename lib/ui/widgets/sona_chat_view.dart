import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:sona/ui/theme/colors.dart';

class SonaChatView extends StatelessWidget {
  final ChatController chatController;
  final ChatViewState chatViewState;
  final StringMessageCallBack? sendMessage;
  final bool enableCameraImagePicker;
  final bool enableGalleryImagePicker;
  final bool allowRecordingVoice;

  const SonaChatView({
    super.key,
    required this.chatController,
    required this.chatViewState,
    this.sendMessage,
    this.enableCameraImagePicker = true,
    this.enableGalleryImagePicker = true,
    this.allowRecordingVoice = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    const chatBubbleSenderNameTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    const padding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    final receiptsWidgetConfig = ReceiptsWidgetConfig(
      lastSeenAgoBuilder: (Message message, String formattedDate) {
        return Text(
          'Hace $formattedDate',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        );
      },
      showReceiptsIn: ShowReceiptsIn.all,
      receiptsBuilder: (status) {
        return switch (status) {
          MessageStatus.pending => const Icon(Icons.access_time, size: 15, color: Colors.grey),
          MessageStatus.read => Icon(Icons.done_all, size: 15, color: primaryColor),
          MessageStatus.delivered => const Icon(Icons.done, size: 15, color: Colors.grey),
          MessageStatus.undelivered => const Icon(Icons.error, size: 15, color: Colors.red),
        };
      },
    );

    final inComingChatBubbleConfig = ChatBubble(
      color: teal,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      padding: padding,
      senderNameTextStyle: chatBubbleSenderNameTextStyle,
      receiptsWidgetConfig: receiptsWidgetConfig,
    );

    final outgoingChatBubbleConfig = ChatBubble(
      color: primaryColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
        bottomLeft: Radius.circular(10),
      ),
      padding: padding,
      senderNameTextStyle: chatBubbleSenderNameTextStyle,
      receiptsWidgetConfig: receiptsWidgetConfig,
    );

    return ChatView(
      chatController: chatController,
      chatViewState: chatViewState,
      featureActiveConfig: const FeatureActiveConfig(
        enableReactionPopup: false,
        enableDoubleTapToLike: false,
        enableOtherUserProfileAvatar: true,
        enableCurrentUserProfileAvatar: true,
      ),
      onSendTap: sendMessage,
      chatBackgroundConfig: const ChatBackgroundConfiguration(
        backgroundColor: Colors.transparent,
      ),
      chatViewStateConfig: ChatViewStateConfiguration(
        noMessageWidgetConfig: _noMessageWidgetConfig(context),
        errorWidgetConfig: const ChatViewStateWidgetConfiguration(
          widget: Center(
            child: Text(
              'Error al cargar mensajes',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      chatBubbleConfig: ChatBubbleConfiguration(
        inComingChatBubbleConfig: inComingChatBubbleConfig,
        outgoingChatBubbleConfig: outgoingChatBubbleConfig,
      ),
      sendMessageConfig: SendMessageConfiguration(
        replyTitleColor: primaryColor,
        enableCameraImagePicker: enableCameraImagePicker,
        enableGalleryImagePicker: enableGalleryImagePicker,
        allowRecordingVoice: allowRecordingVoice,
        sendButtonIcon: Icon(
          Icons.send,
          color: primaryColor,
        ),
        textFieldConfig: TextFieldConfiguration(
          hintText: 'Escribe un mensaje...',
          borderRadius: BorderRadius.circular(10),
          textStyle: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }

  ChatViewStateWidgetConfiguration _noMessageWidgetConfig(BuildContext context) {
    return const ChatViewStateWidgetConfiguration(
      widget: Center(
        child: Text(
          'No hay mensajes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
