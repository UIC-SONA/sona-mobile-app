import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';

final _log = Logger(level: Level.debug);

class PagingQueryController<T> extends PagingController<int, T> {
  PagingQueryController({
    required int firstPage,
  }) : super(firstPageKey: firstPage);

  void configurePageRequestListener(Future<List<T>> Function(int page) fetcher) {
    addPageRequestListener((pageKey) async {
      final page = pageKey;
      try {
        final items = await fetcher(page);

        final length = items.length;
        final isLastPage = length == 0;
        if (isLastPage) {
          appendLastPage(items);
        } else {
          final nextPageKey = pageKey + 1;
          appendPage(items, nextPageKey);
        }
      } catch (error, stackTrace) {
        _log.e('Error fetching page $page', error: error, stackTrace: stackTrace);
        this.error = error;
      }
    });
  }
}
