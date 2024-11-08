import 'package:sona/application/common/json/json.dart';
import 'package:sona/application/common/models/models.dart';
import 'package:sona/features/menstrualcalendar/models/models.dart';

initJson() {
  Json.registerDefaultsCodecs();
  Json.register<Message>(fromJson: Message.fromJson, toJson: (Message value) => value.toJson());
  Json.register<ProblemDetails>(fromJson: ProblemDetails.fromJson, toJson: (ProblemDetails value) => value.toJson());
  Json.register<MenstrualCycle>(fromJson: MenstrualCycle.fromJson, toJson: (MenstrualCycle value) => value.toJson());
}
