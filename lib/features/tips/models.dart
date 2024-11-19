import 'package:uuid/uuid.dart';

class Tip {
  final Uuid id;
  final String title;
  final String summary;
  final String description;
  final List<String> tags;
  final String image;
  final bool active;

  Tip({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.tags,
    required this.image,
    required this.active,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      image: json['image'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'description': description,
      'tags': tags,
      'image': image,
      'active': active,
    };
  }
}
