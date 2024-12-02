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

    final chatBubbleRadius = BorderRadius.circular(10);
    const chatBubbleSenderNameTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    final inComingChatBubbleConfig = ChatBubble(
      color: primaryColor,
      borderRadius: chatBubbleRadius,
      senderNameTextStyle: chatBubbleSenderNameTextStyle,
    );

    final outgoingChatBubbleConfig = ChatBubble(
      color: magenta,
      borderRadius: chatBubbleRadius,
      senderNameTextStyle: chatBubbleSenderNameTextStyle,
    );

    return ChatView(
      chatController: chatController,
      chatViewState: chatViewState,
      onSendTap: sendMessage,
      chatBackgroundConfig: const ChatBackgroundConfiguration(
        backgroundColor: Colors.transparent,
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
}
