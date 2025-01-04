import 'package:sona/domain/models/chat_bot.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';

abstract class ChatBotService {
  Future<PromptResponse> sendMessage(String prompt);

  Future<List<PromptResponse>> getChatHistory();
}

class ApiChatBotService implements ChatBotService {
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiChatBotService({required this.authProvider, required this.localeProvider});

  @override
  Future<PromptResponse> sendMessage(String prompt) async {
    final response = await request(
      apiUri.replace(path: '/chatbot/send-message'),
      client: authProvider.client!,
      method: HttpMethod.post,
      headers: {
        'Accept-Language': localeProvider.languageCode,
      },
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
      headers: {
        'Accept-Language': localeProvider.languageCode,
      },
    );

    return response.getBody<List<PromptResponse>>();
  }
}
