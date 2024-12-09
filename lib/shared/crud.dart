import 'package:sona/shared/schemas/page.dart';

abstract interface class Listable<T> {
  Future<List<T>> list([String? search]);
}

abstract interface class Paginable<T> {
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

abstract interface class ReadOperations<T, ID> implements Findable<T, ID>, Listable<T>, Paginable<T>, Countable, Existable<ID> {}

abstract interface class WriteOperations<T, D, ID> implements Creatable<T, D>, Updatable<T, D, ID>, Deletable<ID> {}

abstract interface class CrudOperations<T, D, ID> implements ReadOperations<T, ID>, WriteOperations<T, D, ID> {}
