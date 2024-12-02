import 'package:sona/domain/models/promp_response.dart';
import 'package:sona/domain/services/auth.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';

abstract class ChatBotService {
  Future<PromptResponse> sendMessage(String prompt);

  Future<List<PromptResponse>> getChatHistory();
}

class ApiChatBotService implements ChatBotService {
  final AuthProvider authProvider;

  ApiChatBotService({required this.authProvider});

  @override
  Future<PromptResponse> sendMessage(String prompt) async {
    final response = await request(
      apiUri.replace(path: '/chatbot/send-message'),
      client: authProvider.client!,
      method: HttpMethod.post,
      body: {'prompt': prompt},
    );

    return response.getBody<PromptResponse>();
  }

  @override
  Future<List<PromptResponse>> getChatHistory() async {
    final response = await request(
      apiUri.replace(path: '/chatbot/history'),
      client: authProvider.client!,
      method: HttpMethod.get,
    );

    return response.getBody<List<PromptResponse>>();
  }
}
