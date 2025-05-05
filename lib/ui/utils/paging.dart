import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PagingRequestController<T> extends PagingController<int, T> {
  Future<List<T>> Function(int page) fetcher;

  PagingRequestController(this.fetcher)
      : super(
          getNextPageKey: (state) => (state.keys?.last ?? -1) + 1,
          fetchPage: fetcher,
        );

  /// Fetches the next page.
  ///
  /// If called while a page is fetching or no more pages are available, this method does nothing.
  @override
  void fetchNextPage() async {
    if (value.pages?.last.isEmpty == true && value.error == null) {
      value = value.copyWith(hasNextPage: false);
    }
    super.fetchNextPage();
  }
}
