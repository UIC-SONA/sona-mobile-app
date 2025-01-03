import 'package:flutter/material.dart';
import 'dart:async';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, bool isSelected);

class SearchDropdown<T> extends StatefulWidget {
  final Future<List<T>> Function(String query, int page) onSearch;
  final void Function(T value) onSelected;
  final ItemBuilder<T> itemBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final InputDecoration? inputDecoration;
  final Duration debounceTime;
  final double? maxHeight;
  final BoxDecoration? dropdownDecoration;
  final T? selectedItem;
  final int pageSize;
  final bool hideOnEmpty;
  final List<dynamic> dependencies;

  const SearchDropdown({
    super.key,
    required this.onSearch,
    required this.onSelected,
    required this.itemBuilder,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.inputDecoration,
    this.debounceTime = const Duration(milliseconds: 500),
    this.maxHeight = 200,
    this.dropdownDecoration,
    this.selectedItem,
    this.pageSize = 20,
    this.hideOnEmpty = false,
    this.dependencies = const [],
  });

  @override
  State<SearchDropdown<T>> createState() => _SearchDropdownState<T>();
}

class _SearchDropdownState<T> extends State<SearchDropdown<T>> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  Set<T> _items = {};
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.hideOnEmpty) {
      _isLoading = false;
    } else {
      _loadMore();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (dependenciesChanged(oldWidget.dependencies, widget.dependencies)) {
      _onSearchChanged(_controller.text);
    }
  }

  static bool dependenciesChanged(List<dynamic> oldDependencies, List<dynamic> newDependencies) {
    if (oldDependencies.length != newDependencies.length) {
      return true;
    }

    for (var i = 0; i < oldDependencies.length; i++) {
      if (oldDependencies[i] != newDependencies[i]) {
        return true;
      }
    }

    return false;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final newItems = await widget.onSearch(_lastQuery, _currentPage + 1);

      if (newItems.length < widget.pageSize) {
        _hasMore = false;
      }

      _items.addAll(newItems);
      _currentPage++;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    _lastQuery = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(widget.debounceTime, () async {
      setState(() {
        _isLoading = true;
        _items.clear();
        _currentPage = 1;
        _hasMore = true;
      });

      if (query.isEmpty && widget.hideOnEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      try {
        final results = await widget.onSearch(query, 1);
        setState(() {
          _items = results.toSet();
          if (results.length < widget.pageSize) {
            _hasMore = false;
          }
        });
      } finally {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          decoration: widget.inputDecoration ??
              const InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 4),
        if (widget.hideOnEmpty && _controller.text.isEmpty)
          Container()
        else
          Container(
            constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 200),
            decoration: widget.dropdownDecoration,
            child: _buildResultsList(),
          )
      ],
    );
  }

  Widget _buildResultsList() {
    final items = _items.toList();

    if (_isLoading && items.isEmpty) {
      return widget.loadingBuilder?.call(context) ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    if (items.isEmpty) {
      return widget.noItemsFoundBuilder?.call(context) ??
          const Center(
            child: Text('No se encontraron resultados'),
          );
    }

    return Scrollbar(
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: items.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return InkWell(
            onTap: () => widget.onSelected(items[index]),
            child: widget.itemBuilder(context, items[index], items[index] == widget.selectedItem),
          );
        },
      ),
    );
  }
}
