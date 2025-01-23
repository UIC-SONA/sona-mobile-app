class Tip {
  final String id;
  final String title;
  final String summary;
  final String description;
  final List<String> tags;
  final bool active;
  final int? myRate;
  final double averageRate;
  final int totalRate;

  Tip({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.tags,
    required this.active,
    this.myRate,
    required this.averageRate,
    required this.totalRate,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      active: json['active'],
      myRate: json['myRate'],
      averageRate: json['averageRate'] ?? 0.0,
      totalRate: json['totalRate'] ?? 0,
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
      'myValuation': myRate,
      'averageValuation': averageRate,
      'totalValuations': totalRate,
    };
  }
}
