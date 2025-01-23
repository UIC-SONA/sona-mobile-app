class ProblemDetails {
  final Uri type;
  final String title;
  final int status;
  final String detail;
  final Uri instance;
  final Map<String, dynamic> extensions = {};

  ProblemDetails({required this.type, required this.title, required this.status, required this.detail, required this.instance});

  factory ProblemDetails.fromJson(Map<String, dynamic> json) {
    var type = json['type'];
    if (type is String) type = Uri.parse(type);
    type ??= Uri.parse('about:blank');

    var problemDetail = ProblemDetails(
      type: type,
      title: json['title'],
      status: json['status'],
      detail: json['detail'],
      instance: json['instance'] != null ? Uri.parse(json['instance']) : Uri.parse('about:blank'),
    );
    json.keys.where((key) => !['type', 'title', 'status', 'detail', 'instance'].contains(key)).forEach((key) {
      problemDetail.extensions[key] = json[key];
    });
    return problemDetail;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'status': status,
      'detail': detail,
      'instance': instance,
      ...extensions,
    };
  }
}