import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/shared/schemas/page.dart';

final _log = Logger(level: Level.debug);

class PagingQueryController<T> extends PagingController<int, T> {
  String? _search;
  int size;
  List<String>? properties;
  Direction? direction;

  PagingQueryController({
    required int firstPage,
    String? search,
    this.size = 5,
    this.properties,
    this.direction,
  })  : _search = search,
        super(firstPageKey: firstPage);

  void configureFetcher(Future<Page<T>> Function(PageQuery query) fetcher) {
    addPageRequestListener((pageKey) async {
      _log.i('Fetching page $pageKey');
      final pageNumber = pageKey ~/ size;
      try {
        final page = await fetcher(PageQuery(
          search: _search,
          page: pageNumber,
          size: size,
          properties: properties,
          direction: direction,
        ));

        _log.i('Date fetched for page $pageNumber, data: $page');
        final content = page.content;
        final length = content.length;

        final isLastPage = page.page.totalPages == pageNumber + 1;
        if (isLastPage) {
          appendLastPage(content);
        } else {
          final nextPageKey = pageKey + length;
          appendPage(content, nextPageKey);
        }
      } catch (error, stackTrace) {
        _log.e('Error fetching page $pageNumber', error: error, stackTrace: stackTrace);
        this.error = error;
      }
    });
  }

  void sort(List<String> properties, Direction direction) {
    this.properties = properties;
    this.direction = direction;
    refresh();
  }

  void search(String search) {
    _search = search;
    refresh();
  }

  void reset() {
    _search = null;
    properties = null;
    direction = null;
    refresh();
  }
}
