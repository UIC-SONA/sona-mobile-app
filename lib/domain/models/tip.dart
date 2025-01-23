class Tip {
  final String id;
  final String title;
  final String summary;
  final String description;
  final List<String> tags;
  final bool active;
  final int? myValuation;
  final double averageValuation;
  final int totalValuations;

  Tip({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.tags,
    required this.active,
    this.myValuation,
    required this.averageValuation,
    required this.totalValuations,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      active: json['active'],
      myValuation: json['myValuation'],
      averageValuation: json['averageValuation'] ?? 0.0,
      totalValuations: json['totalValuations'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'description': description,
      'tags': tags,
      'active': active,
      'myValuation': myValuation,
      'averageValuation': averageValuation,
      'totalValuations': totalValuations,
    };
  }
}
