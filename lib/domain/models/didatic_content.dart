class DidaticContent {
  final String id;
  final String title;
  final String content;
  final String image;

  DidaticContent({
    required this.id,
    required this.title,
    required this.content,
    required this.image,
  });

  factory DidaticContent.fromJson(Map<String, dynamic> json) {
    return DidaticContent(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image': image,
    };
  }
}
