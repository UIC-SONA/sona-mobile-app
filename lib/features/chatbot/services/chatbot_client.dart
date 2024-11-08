import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/dialogflow/v3.dart' as df;
import 'package:logger/logger.dart';

Logger _log = Logger();

class AuthClient {
  static const _scopes = [df.DialogflowApi.cloudPlatformScope];

  static Future<df.DialogflowApi> getDialogflowApi() async {
    final serviceAccountJson = await rootBundle.loadString('assets/service_account.json');
    final credentials = ServiceAccountCredentials.fromJson(json.decode(serviceAccountJson));
    final client = await clientViaServiceAccount(credentials, _scopes);
    return df.DialogflowApi(client, rootUrl: 'https://dialogflow.googleapis.com/');
  }
}

class ChatbotClient {
  final String projectId;
  final String agentId;
  final String location;

  ChatbotClient({required this.projectId, required this.agentId, required this.location});

  Future<String> sendMessage(String sessionId, String message) async {
    final dialogflow = await AuthClient.getDialogflowApi();
    final sessionPath = 'projects/$projectId/locations/$location/agents/$agentId/sessions/$sessionId';
    final queryInput = df.GoogleCloudDialogflowCxV3QueryInput(
      languageCode: 'es',
      text: df.GoogleCloudDialogflowCxV3TextInput(text: message),
    );

    final response = await dialogflow.projects.locations.agents.sessions.detectIntent(
      df.GoogleCloudDialogflowCxV3DetectIntentRequest(queryInput: queryInput),
      sessionPath,
    );

    final df.GoogleCloudDialogflowCxV3QueryResult? queryResult = response.queryResult;
    _log.i('Query result: ${queryResult?.toJson()}');
    if (queryResult != null && queryResult.responseMessages != null && queryResult.responseMessages!.isNotEmpty) {
      return queryResult.responseMessages!.first.text!.text!.first;
    } else {
      return 'No response from chatbot';
    }
  }
}
