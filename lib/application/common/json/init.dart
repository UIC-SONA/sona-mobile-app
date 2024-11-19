import 'package:sona/application/common/json/json.dart';
import 'package:sona/application/common/models/models.dart';
import 'package:sona/features/menstrualcalendar/models.dart';
import 'package:sona/features/tips/models.dart';

registerJsonCodecs() {
  Json.registerDefaultsCodecs();
  Json.register<Message>(fromJson: Message.fromJson, toJson: (Message value) => value.toJson());
  Json.register<ProblemDetails>(fromJson: ProblemDetails.fromJson, toJson: (ProblemDetails value) => value.toJson());
  Json.register<MenstrualCycle>(fromJson: MenstrualCycle.fromJson, toJson: (MenstrualCycle value) => value.toJson());
  Json.register<Tip>(fromJson: Tip.fromJson, toJson: (Tip value) => value.toJson());
}
