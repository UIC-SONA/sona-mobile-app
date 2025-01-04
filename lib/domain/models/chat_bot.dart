class PromptResponse {
  //
  final String prompt;

  final List<String> responses;

  final DateTime timestamp;

  PromptResponse({required this.prompt, required this.responses, required this.timestamp});

  factory PromptResponse.fromJson(Map<String, dynamic> json) {
    return PromptResponse(
      prompt: json['prompt'],
      responses: List<String>.from(json['responses']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'responses': responses,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
