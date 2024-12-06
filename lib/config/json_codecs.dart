import 'package:sona/domain/models/models.dart';
import 'package:sona/shared/json.dart';
import 'package:sona/shared/schemas/message.dart';
import 'package:sona/shared/schemas/page.dart';

setupJsonCodecs() {
  //
  Json.registerDefaultsCodecs();
  Json.register<Message>(fromJson: Message.fromJson, toJson: (Message value) => value.toJson());
  Json.register<ProblemDetails>(fromJson: ProblemDetails.fromJson, toJson: (value) => value.toJson());
  Json.register<MenstrualCycle>(fromJson: MenstrualCycle.fromJson, toJson: (value) => value.toJson());
  Json.register<Tip>(fromJson: Tip.fromJson, toJson: (value) => value.toJson());
  Json.register<User>(fromJson: User.fromJson, toJson: (value) => value.toJson());
  Json.register<UserInfo>(fromJson: UserInfo.fromJson, toJson: (value) => value.toJson());
  Json.register<UserRepresentation>(fromJson: UserRepresentation.fromJson, toJson: (value) => value.toJson());
  Json.register<PromptResponse>(fromJson: PromptResponse.fromJson, toJson: (value) => value.toJson());
  Json.register<PageMap>(fromJson: PageMap.fromJson, toJson: (value) => value.toJson());
  Json.register<PageInfo>(fromJson: PageInfo.fromJson, toJson: (value) => value.toJson());
  Json.register<PageQuery>(fromJson: PageQuery.fromJson, toJson: (value) => value.toJson());
  Json.register<ChatMessage>(fromJson: ChatMessage.fromJson, toJson: (value) => value.toJson());
  Json.register<ChatRoom>(fromJson: ChatRoom.fromJson, toJson: (value) => value.toJson());
  Json.register<ChatMessageSent>(fromJson: ChatMessageSent.fromJson, toJson: (value) => value.toJson());
}
