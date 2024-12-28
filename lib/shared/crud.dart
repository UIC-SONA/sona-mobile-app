import 'schemas/page.dart';
import 'schemas/direction.dart';

abstract interface class Pageable<T> {
  Future<Page<T>> page([PageQuery? query]);
}

abstract interface class Findable<T, ID> {
  Future<T> find(ID id);

  Future<List<T>> findMany(List<ID> ids);
}

abstract interface class Countable {
  Future<int> count();
}

abstract interface class Existable<ID> {
  Future<bool> exists(ID id);
}

abstract interface class Creatable<T, D> {
  Future<T> create(D dto);
}

abstract interface class Updatable<T, D, ID> {
  Future<T> update(ID id, D dto);
}

abstract interface class Deletable<ID> {
  Future<void> delete(ID id);
}

abstract interface class ReadOperations<T, ID> implements Findable<T, ID>, Pageable<T>, Countable, Existable<ID> {}

abstract interface class WriteOperations<T, D, ID> implements Creatable<T, D>, Updatable<T, D, ID>, Deletable<ID> {}

abstract interface class CrudOperations<T, D, ID> implements ReadOperations<T, ID>, WriteOperations<T, D, ID> {}

enum FilterOperator {
  eq("eq"),
  ne("ne"),
  gt("gt"),
  ge("ge"),
  lt("lt"),
  le("le"),
  in_("in"),
  nin("nin"),
  like("like"),
  isNull("isNull"),
  notNull("notNull");

  final String value;

  const FilterOperator(this.value);
}

class Filter {
  final String property;
  final FilterOperator operator;
  final dynamic value;

  Filter({
    required this.property,
    required this.operator,
    required this.value,
  });

  String toQueryParameter() {
    return '$property:${operator.value}:${scape(value)}';
  }

  static String scape(dynamic value) {
    return value.toString().replaceAll(',', r'\,').replaceAll(':', r'\:');
  }
}

class PageQuery {
  final String? search;
  final List<String>? properties;
  final Direction? direction;
  final List<Filter>? filters;
  final int? page;
  final int? size;

  PageQuery({
    this.search,
    this.properties,
    this.direction,
    this.filters,
    this.page,
    this.size,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'search': search,
      'properties': properties?.join(','),
      'direction': direction?.value,
      'filters': filters?.map((e) => e.toQueryParameter()).join(','),
      'page': page?.toString(),
      'size': size?.toString(),
    };
  }

  PageQuery copyWith({
    String? search,
    List<String>? properties,
    Direction? direction,
    List<Filter>? filters,
    int? page,
    int? size,
  }) {
    return PageQuery(
      search: search ?? this.search,
      properties: properties ?? this.properties,
      direction: direction ?? this.direction,
      filters: filters ?? this.filters,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }
}
