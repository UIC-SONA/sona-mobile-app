class Post extends ByAuthor<int> {
  final String id;
  final String content;
  final List<String> images;
  final List<Comment> comments;
  final List<int> likedBy;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.content,
    required this.images,
    required this.comments,
    required this.likedBy,
    required this.createdAt,
    required int? author,
  }) : super(author);

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      images: List<String>.from(json['images']),
      comments: List<Comment>.from(json['comments'].map((x) => Comment.fromJson(x))),
      likedBy: List<int>.from(json['likedBy']),
      createdAt: DateTime.parse(json['createdAt']),
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'images': images,
      'comments': comments.map((x) => x.toJson()).toList(),
      'likedBy': likedBy,
      'createdAt': createdAt.toIso8601String(),
      'author': author,
    };
  }

  @override
  String toString() {
    return 'Post{id: $id, content: $content, images: $images, comments: $comments, likedBy: $likedBy, createdAt: $createdAt}';
  }
}

class Comment extends ByAuthor<int> {
  final String id;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required int? author,
  }) : super(author);

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'author': author,
    };
  }
}

class ByAuthor<T> {
  final T? author; // if null, is anonymous

  ByAuthor(this.author);
}
