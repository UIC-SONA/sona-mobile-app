import 'package:http/http.dart' as http;
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/http/extensions.dart';
import 'package:sona/shared/http/request.dart';
import 'package:sona/shared/http/types.dart';
import 'package:sona/shared/json.dart';
import 'package:sona/shared/schemas/page.dart';

Future<List<T>> _list<T>(Uri uri, String path, Map<String, String> headers, http.Client? client, [Query? query]) async {
  final response = await request(
    uri.replace(path: path, queryParameters: query?.toQueryParameters()),
    client: client,
    method: HttpMethod.get,
    headers: {
      ...headers,
      'Accept': 'application/json',
    },
  );
  return response.getBody<List<T>>();
}

Future<Page<T>> _page<T>(Uri uri, String path, Map<String, String> headers, http.Client? client, [PageQuery? query]) async {
  final response = await request(
    uri.replace(path: '$path/page', queryParameters: query?.toQueryParameters()),
    client: client,
    method: HttpMethod.get,
    headers: {
      ...headers,
      'Accept': 'application/json',
    },
  );
  return response.getBody<PageMap>().as<T>();
}

Future<T> _find<T, ID>(Uri uri, String path, Map<String, String> headers, http.Client? client, ID id) async {
  final response = await request(
    uri.replace(path: '$path/$id'),
    client: client,
    method: HttpMethod.get,
    headers: {
      ...headers,
      'Accept': 'application/json',
    },
  );
  return response.getBody<T>();
}

@override
Future<List<T>> _findMany<T, ID>(Uri uri, String path, Map<String, String> headers, http.Client? client, List<ID> ids) async {
  final response = await request(
    uri.replace(path: '$path/ids', queryParameters: {'ids': ids.map((id) => id.toString()).join(',')}),
    client: client,
    method: HttpMethod.get,
    headers: {
      ...headers,
      'Content-Type': 'application/json',
    },
  );
  return response.getBody<List<T>>();
}

Future<int> _count(Uri uri, String path, Map<String, String> headers, http.Client? client) async {
  final response = await request(
    uri.replace(path: '$path/count'),
    client: client,
    method: HttpMethod.get,
    headers: headers,
  );
  return int.parse(response.body);
}

Future<bool> _exists<ID>(Uri uri, String path, Map<String, String> headers, http.Client? client, ID id) async {
  final response = await request(
    uri.replace(path: '$path/exists'),
    client: client,
    method: HttpMethod.get,
    headers: headers,
    body: id.toString(),
  );
  return bool.parse(response.body);
}

Future<T> _create<T, D>(Uri uri, String path, Map<String, String> headers, http.Client? client, D dto) async {
  final response = await request(
    uri.replace(path: path),
    client: client,
    method: HttpMethod.post,
    headers: {
      ...headers,
      'Content-Type': 'application/json',
    },
    body: Json.serialize(dto),
  );
  return response.getBody<T>();
}

Future<T> _update<T, D, ID>(Uri uri, String path, Map<String, String> headers, http.Client? client, ID id, D dto) async {
  final response = await request(
    uri.replace(path: '$path/$id'),
    client: client,
    method: HttpMethod.put,
    headers: {
      ...headers,
      'Content-Type': 'application/json',
    },
    body: Json.serialize(dto),
  );
  return response.getBody<T>();
}

Future<void> _delete<ID>(Uri uri, String path, Map<String, String> headers, http.Client? client, ID id) async {
  await request(
    uri.replace(path: '$path/$id'),
    client: client,
    method: HttpMethod.delete,
    headers: headers,
  );
}

abstract class RestListable<T> implements WebResource, Listable<T> {
  @override
  Future<List<T>> list([Query? query]) async => _list<T>(uri, path, commonHeaders, client, query);
}

abstract class RestPaginable<T> implements WebResource, Pageable<T> {
  @override
  Future<Page<T>> page([PageQuery? query]) async => _page<T>(uri, path, commonHeaders, client, query);
}

abstract interface class RestFindable<T, ID> implements WebResource, Findable<T, ID> {
  @override
  Future<T> find(ID id) async => _find<T, ID>(uri, path, commonHeaders, client, id);

  @override
  Future<List<T>> findMany(List<ID> ids) async => _findMany<T, ID>(uri, path, commonHeaders, client, ids);
}

abstract class RestCountable implements WebResource, Countable {
  @override
  Future<int> count() async => _count(uri, path, commonHeaders, client);
}

abstract class RestExistable<ID> implements WebResource, Existable<ID> {
  @override
  Future<bool> exists(ID id) async => _exists<ID>(uri, path, commonHeaders, client, id);
}

abstract class RestCreatable<T, D> implements WebResource, Creatable<T, D> {
  @override
  Future<T> create(D dto) async => _create<T, D>(uri, path, commonHeaders, client, dto);
}

abstract class RestUpdatable<T, D, ID> implements WebResource, Updatable<T, D, ID> {
  @override
  Future<T> update(ID id, D dto) async => _update<T, D, ID>(uri, path, commonHeaders, client, id, dto);
}

abstract class ApiDeletable<ID> implements WebResource, Deletable<ID> {
  @override
  Future<void> delete(ID id) async => _delete<ID>(uri, path, commonHeaders, client, id);
}

abstract class RestReadOperations<T, ID> implements WebResource, ReadOperations<T, ID> {
  @override
  Future<T> find(ID id) async => _find<T, ID>(uri, path, commonHeaders, client, id);

  @override
  Future<List<T>> findMany(List<ID> ids) async => _findMany<T, ID>(uri, path, commonHeaders, client, ids);

  @override
  Future<List<T>> list([Query? query]) async => _list<T>(uri, path, commonHeaders, client, query);

  @override
  Future<Page<T>> page([PageQuery? query]) async => _page<T>(uri, path, commonHeaders, client, query);

  @override
  Future<int> count() async => _count(uri, path, commonHeaders, client);

  @override
  Future<bool> exists(ID id) async => _exists<ID>(uri, path, commonHeaders, client, id);
}

abstract class RestWriteOperations<T, D, ID> implements WebResource, WriteOperations<T, D, ID> {
  @override
  Future<T> create(D dto) async => _create<T, D>(uri, path, commonHeaders, client, dto);

  @override
  Future<T> update(ID id, D dto) async => _update<T, D, ID>(uri, path, commonHeaders, client, id, dto);

  @override
  Future<void> delete(ID id) async => _delete<ID>(uri, path, commonHeaders, client, id);
}

abstract class RestCrudOperations<T, D, ID> implements WebResource, CrudOperations<T, D, ID> {
  @override
  Future<T> find(ID id) async => _find<T, ID>(uri, path, commonHeaders, client, id);

  @override
  Future<List<T>> findMany(List<ID> ids) async => _findMany<T, ID>(uri, path, commonHeaders, client, ids);

  @override
  Future<List<T>> list([Query? query]) async => _list<T>(uri, path, commonHeaders, client, query);

  @override
  Future<Page<T>> page([PageQuery? query]) async => _page<T>(uri, path, commonHeaders, client, query);

  @override
  Future<int> count() async => _count(uri, path, commonHeaders, client);

  @override
  Future<bool> exists(ID id) async => _exists<ID>(uri, path, commonHeaders, client, id);

  @override
  Future<T> create(D dto) async => _create<T, D>(uri, path, commonHeaders, client, dto);

  @override
  Future<T> update(ID id, D dto) async => _update<T, D, ID>(uri, path, commonHeaders, client, id, dto);

  @override
  Future<void> delete(ID id) async => _delete<ID>(uri, path, commonHeaders, client, id);
}
