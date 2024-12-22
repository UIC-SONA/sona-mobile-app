import 'package:sona/shared/json.dart';

class Page<T> {
  final List<T> content;
  final PageInfo page;

  Page({
    required this.content,
    required this.page,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      content: Json.deserializeDecoded<List<T>>(json['content']),
      page: PageInfo.fromJson(json['page']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'page': page.toJson(),
    };
  }

  Page<R> map<R>(R Function(T) f) {
    return Page<R>(
      content: content.map(f).toList(),
      page: page,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class PageMap extends Page<Map<String, dynamic>> {
  PageMap({
    required super.content,
    required super.page,
  });

  factory PageMap.fromJson(Map<String, dynamic> json) {
    return PageMap(
      content: List<Map<String, dynamic>>.from(json['content']),
      page: PageInfo.fromJson(json['page']),
    );
  }

  Page<T> as<T>() {
    return Page<T>(
      content: Json.deserializeDecoded<List<T>>(content),
      page: page,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class PageInfo {
  final int size;
  final int number;
  final int totalPages;
  final int totalElements;

  PageInfo({
    required this.size,
    required this.number,
    required this.totalPages,
    required this.totalElements,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      size: json['size'],
      number: json['number'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'number': number,
      'totalPages': totalPages,
      'totalElements': totalElements,
    };
  }
}
