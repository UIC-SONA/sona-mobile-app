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

class Sort {
  final String property;
  final Direction direction;

  Sort(this.property, this.direction);
}

class PageQuery {
  final String? search;
  final int? page;
  final int? size;
  final List<Sort> sort;
  final String? query; //rsql query
  final Map<String, Iterable<String>> params;

  PageQuery({
    this.search,
    this.page,
    this.size,
    this.sort = const [],
    this.query,
    this.params = const {},
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'search': search,
      'page': page?.toString(),
      'size': size?.toString(),
      'sort': [
        for (final s in sort) '${s.property},${s.direction.value}',
      ],
      'query': query,
      ...params,
    };
  }

  PageQuery copyWith({
    String? search,
    int? page,
    int? size,
    List<Sort>? sort,
    Map<String, List<String>>? params,
  }) {
    return PageQuery(
      search: search ?? this.search,
      page: page ?? this.page,
      size: size ?? this.size,
      sort: sort ?? this.sort,
      params: params ?? this.params,
    );
  }
}
