import 'types.dart';
import 'extensions.dart';
import 'exceptions.dart';

Future<T> onNotFound<T>({required Future<T> Function() fetch, required T Function() onNotFound}) async {
  try {
    return await fetch();
  } on HttpException catch (e) {
    if (e.response != null && e.response!.status == HttpStatusCode.notFound) {
      return onNotFound();
    }
    rethrow;
  }
}
