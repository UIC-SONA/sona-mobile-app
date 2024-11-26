import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/models/tip.dart';

import '../shared/json.dart';

setupJsonCodecs() {
  Json.registerDefaultsCodecs();
  Json.register<Message>(fromJson: Message.fromJson, toJson: (Message value) => value.toJson());
  Json.register<ProblemDetails>(fromJson: ProblemDetails.fromJson, toJson: (ProblemDetails value) => value.toJson());
  Json.register<MenstrualCycle>(fromJson: MenstrualCycle.fromJson, toJson: (MenstrualCycle value) => value.toJson());
  Json.register<Tip>(fromJson: Tip.fromJson, toJson: (Tip value) => value.toJson());
  Json.register<User>(fromJson: User.fromJson, toJson: (User value) => value.toJson());
  Json.register<UserRepresentation>(fromJson: UserRepresentation.fromJson, toJson: (UserRepresentation value) => value.toJson());
}
