import 'package:flutter/foundation.dart';

class ListNotifier<T> extends ChangeNotifier implements ValueListenable<List<T>> {
  final List<T> _list = [];

  List<T> get list => _list;

  void add(T item) {
    _list.add(item);
    notifyListeners();
  }

  void addAll(List<T> items) {
    _list.addAll(items);
    notifyListeners();
  }

  void remove(T item) {
    _list.remove(item);
    notifyListeners();
  }

  void removeAt(int index) {
    _list.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _list.clear();
    notifyListeners();
  }

  void update(T item) {
    final index = _list.indexWhere((element) => element == item);
    if (index != -1) {
      _list[index] = item;
      notifyListeners();
    }
  }

  void updateAt(int index, T item) {
    _list[index] = item;
    notifyListeners();
  }

  void replaceAll(List<T> items) {
    _list.clear();
    _list.addAll(items);
    notifyListeners();
  }

  bool contains(T item) => _list.contains(item);

  @override
  List<T> get value => _list;
}
