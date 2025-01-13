import 'package:flutter/material.dart';
import 'dart:async';

import 'package:sona/ui/utils/iterable_utils.dart';
import 'package:sona/ui/utils/list_listenner.dart';
import 'package:sona/ui/widgets/multi_value_listenable_builder.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, bool isSelected);
typedef DisplayMapper<T> = String Function(T item);

class SearchDropdown<T> extends StatefulWidget {
  final T? initialSelected;
  final void Function(T? value) onSelected;
  final bool Function(T value1, T value2) areEqual;
  final Future<List<T>> Function(String query, int page) onSearch;
  final ItemBuilder<T> itemBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final DisplayMapper<T> displayMapper;
  final InputDecoration? inputDecoration;
  final Duration debounceTime;
  final double? maxHeight;
  final BoxDecoration? dropdownDecoration;
  final int pageSize;
  final bool hideOnEmpty;
  final List<dynamic> dependencies;

  SearchDropdown({
    super.key,
    this.initialSelected,
    required this.onSelected,
    bool Function(T value1, T value2)? areEqual,
    required this.onSearch,
    required this.itemBuilder,
    this.loadingBuilder,
    required this.displayMapper,
    this.noItemsFoundBuilder,
    this.inputDecoration,
    this.debounceTime = const Duration(milliseconds: 500),
    this.maxHeight = 200,
    this.dropdownDecoration,
    this.pageSize = 20,
    this.hideOnEmpty = false,
    this.dependencies = const [],
  }) : areEqual = areEqual ?? ((value1, value2) => value1 == value2);

  @override
  State<SearchDropdown<T>> createState() => _SearchDropdownState<T>();
}

class _SearchDropdownState<T> extends State<SearchDropdown<T>> {
  final _selected = ValueNotifier<T?>(null);
  final _items = ListNotifier<T>();
  final _loading = ValueNotifier<bool>(false);
  final _isOpen = ValueNotifier<bool>(false);
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _layerLink = LayerLink();

  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  int _currentPage = 1;
  bool _hasMore = true;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _selected.value = widget.initialSelected;
    if (widget.initialSelected != null) {
      _controller.text = widget.displayMapper(widget.initialSelected as T);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _selected.dispose();
    _items.dispose();
    _loading.dispose();
    _isOpen.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isEqualsList(widget.dependencies, oldWidget.dependencies)) {
      _onSearchChanged(_lastQuery);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_isOpen.value) _toggleDropdown();
        },
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height),
                child: Card(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 200),
                    decoration: widget.dropdownDecoration ??
                        BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                    child: _buildResultsList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _toggleDropdown() {
    if (!_isOpen.value) {
      _isOpen.value = true;
      _showOverlay();
      if (_items.value.isEmpty && !widget.hideOnEmpty) {
        _onSearchChanged('');
      }
    } else {
      _isOpen.value = false;
      _removeOverlay();
    }
  }

  void _handleItemSelected(T item) {
    widget.onSelected(item);
    _selected.value = item;
    _controller.text = widget.displayMapper(item);
    _toggleDropdown();
  }

  void _onClear() {
    widget.onSelected(null);
    _controller.clear();
    _selected.value = null;
    _items.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: ValueListenableBuilder(
        valueListenable: _isOpen,
        builder: (context, isOpen, _) => GestureDetector(
          onTap: _toggleDropdown,
          child: ValueListenableBuilder(
            valueListenable: _selected,
            builder: (context, selected, _) {
              return TextField(
                controller: _controller,
                decoration: widget.inputDecoration?.copyWith(
                      suffixIcon: selected != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _onClear,
                            )
                          : null,
                    ) ??
                    InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: selected != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _onClear,
                            )
                          : null,
                    ),
                onChanged: (value) {
                  if (!_isOpen.value) _toggleDropdown();
                  _onSearchChanged(value);
                },
                onTap: () {
                  if (!_isOpen.value) {
                    _loading.value = true;
                    _toggleDropdown();
                    _onSearchChanged('');
                  }
                },
                readOnly: _selected.value != null,
              );
            },
          ),
        ),
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (!_loading.value && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading.value) return;
    _loading.value = true;

    try {
      final newItems = await widget.onSearch(_lastQuery, _currentPage + 1);

      if (newItems.length < widget.pageSize) {
        _hasMore = false;
      }

      _items.addAll(newItems);
      _currentPage++;
    } finally {
      _loading.value = false;
    }
  }

  void _onSearchChanged(String query) {
    _lastQuery = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(widget.debounceTime, () async {
      _loading.value = true;
      _items.clear();

      //
      _currentPage = 1;
      _hasMore = true;

      try {
        final results = await widget.onSearch(query, 1);
        _items.replaceAll(results);
        if (results.length < widget.pageSize) {
          _hasMore = false;
        }
      } finally {
        _loading.value = false;
      }
    });
  }

  Widget _buildResultsList() {
    return MultiValueListenableBuilder(
      valueListenables: [_items, _loading, _selected],
      builder: (context, args, _) {
        final items = args[0] as List<T>;
        final loading = args[1] as bool;
        final selected = args[2] as T?;

        if (loading && items.isEmpty) {
          return widget.loadingBuilder?.call(context) ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
        }

        if (items.isEmpty) {
          return widget.noItemsFoundBuilder?.call(context) ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No se encontraron resultados'),
                ),
              );
        }

        return Scrollbar(
          child: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: items.length + (loading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final item = items[index];

              return GestureDetector(
                onTap: () => _handleItemSelected(item),
                child: widget.itemBuilder(
                  context,
                  item,
                  selected != null && widget.areEqual(selected, item),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
