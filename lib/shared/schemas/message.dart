class Message {
  final String message;

  Message(this.message);

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(json['message']);
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  @override
  String toString() {
    return 'Message{message: $message}';
  }
}
