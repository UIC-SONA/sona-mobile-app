import 'dart:convert';
import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sona/ui/theme/colors.dart';

import '../theme/icons.dart';


class SonaChatView extends StatelessWidget {
  final ChatController chatController;
  final ChatViewState chatViewState;
  final void Function(
      String message,
      ReplyMessage replyMessage,
      MessageType messageType,
      {String? customType}
      )? sendMessage;
  final bool enableCameraPicker;
  final bool enableGalleryPicker;
  final bool allowRecordingVoice;
  final AsyncCallback? loadMoreData;
  final CustomMessageBuilder? customMessageBuilder;

  const SonaChatView({
    super.key,
    required this.chatController,
    required this.chatViewState,
    this.sendMessage,
    this.enableCameraPicker = true,
    this.enableGalleryPicker = true,
    this.allowRecordingVoice = true,
    this.loadMoreData,
    this.customMessageBuilder,
  });


  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme
        .of(context)
        .primaryColor;

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
      loadMoreData: loadMoreData,
      chatController: chatController,
      chatViewState: chatViewState,
      featureActiveConfig: const FeatureActiveConfig(
        enableReactionPopup: false,
        enableDoubleTapToLike: false,
        enableOtherUserProfileAvatar: true,
        enableCurrentUserProfileAvatar: false,
        enableReplySnackBar: false,
        enableSwipeToReply: false,
      ),
      onSendTap: sendMessage == null ? null : (message,replyMessage,messageType)=> sendMessage!(
        message,
        replyMessage,
        messageType,
      ),
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
      messageConfig: MessageConfiguration(
        imageMessageConfig: ImageMessageConfiguration(
          onTap: (message) => _onTapImage(message, context),
        ),
        customMessageBuilder: customMessageBuilder,
      ),
      sendMessageConfig: SendMessageConfiguration(
        replyTitleColor: primaryColor,
        // enableCameraImagePicker: enableCameraImagePicker,
        // enableGalleryImagePicker: enableGalleryImagePicker,
        allowRecordingVoice: allowRecordingVoice,
        cancelRecordConfiguration: CancelRecordConfiguration(),
        sendButtonIcon: Icon(
          SonaIcons.send,
          color: primaryColor,
        ),
        textFieldConfig: TextFieldConfiguration(
          hintText: 'Escribe un mensaje...',
          borderRadius: BorderRadius.circular(10),
          textStyle: const TextStyle(color: Colors.black, fontSize: 16),
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          trailingActions: (context, textEdtingController) {
            // get widget from context
            return [
              if (enableGalleryPicker) ...[
                /// Botón IMAGEN
                TextFieldActionButton(
                  icon: Icon(Icons.image, color: primaryColor),
                  onPressed: () => pickAndSend(context, isVideo: false),
                ),

                /// Botón VIDEO
                TextFieldActionButton(
                  icon: Icon(Icons.videocam, color: primaryColor),
                  onPressed: () => pickAndSend(context, isVideo: true),
                ),
              ],
            ];
          },
        ),
        voiceRecordingConfiguration: VoiceRecordingConfiguration(
          waveStyle: WaveStyle(
            showMiddleLine: false,
            extendWaveform: true,
          ),
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

  void _onTapImage(Message message, BuildContext context) async {
    final image = message.message;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            Scaffold(
              appBar: AppBar(
                backgroundColor: Theme
                    .of(context)
                    .primaryColor,
                title: const Text('Imagen'),
              ),
              body: InteractiveViewer(
                child: PhotoView(imageProvider: resolveImageProvider(image),),
              ),
            ),
      ),
    );
  }

  Future<void> pickAndSend(BuildContext context, {required bool isVideo}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(isVideo ? Icons.video_library : Icons.photo_library),
                title: Text("Galería"),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(isVideo ? Icons.videocam : Icons.camera_alt),
                title: Text("Cámara"),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final XFile? media = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);

    if (media == null || media.path.isEmpty) return;

    final mimeType = lookupMimeType(media.path) ?? '';
    if (mimeType.isEmpty) return;

    final (messageType, customType) = resolveMessageType(mimeType);
    sendMessage?.call(media.path, ReplyMessage(), messageType, customType: customType);

    chatController.scrollToLastMessage();
  }
}


(MessageType type, String? customType) resolveMessageType(String mimeType) {
  if (mimeType.startsWith('image/')) {
    return (MessageType.image, null);
  }
  if (mimeType.startsWith('video/')) {
    return (MessageType.custom, 'video');
  }
  return (MessageType.custom, null);
}


ImageProvider<Object> resolveImageProvider(String image) {
  if (image.startsWith('data:image')) {
    return MemoryImage(base64Decode(image.substring(image.indexOf('base64') + 7)));
  }
  if (Uri
      .tryParse(image)
      ?.isAbsolute ?? false) {
    return NetworkImage(image);
  }

  return FileImage(File(image));
}
