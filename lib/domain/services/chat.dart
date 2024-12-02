import 'package:sona/domain/services/auth.dart';

abstract class ChatService {
  //Future<List<User>> listUsers();
}

class ApiChatService implements ChatService {
  final AuthProvider authProvider;

  ApiChatService({required this.authProvider});
}
