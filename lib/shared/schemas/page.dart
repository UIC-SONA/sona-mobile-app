import 'package:sona/shared/http/types.dart';
import 'package:sona/shared/json.dart';
import 'package:sona/shared/schemas/direction.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'page': page.toJson(),
    };
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

class PageQuery extends QueryParametrable {
  final String? search;
  final int? page;
  final int? size;
  final List<String>? properties;
  final Direction? direction;

  PageQuery({
    this.search,
    this.page,
    this.size,
    this.properties,
    this.direction,
  });

  factory PageQuery.fromJson(Map<String, dynamic> json) {
    return PageQuery(
      search: json['search'],
      page: json['page'],
      size: json['size'],
      properties: List<String>.from(json['properties']),
      direction: Direction.fromString(json['direction']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'page': page,
      'size': size,
      'properties': properties,
      'direction': direction?.value,
    };
  }

  @override
  Map<String, dynamic> toQueryParameters() {
    return {
      'search': search,
      'page': page?.toString(),
      'size': size?.toString(),
      'properties': properties?.join(','),
      'direction': direction?.value,
    };
  }
}
