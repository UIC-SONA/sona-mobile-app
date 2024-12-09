import 'package:sona/shared/extensions.dart';

class ValidationException implements Exception {
  final String message;
  final String validation;

  ValidationException(this.message, Function validation) : validation = validation.toString();
}

T requiredType<T>(Map<String, dynamic> map, String key) {
  final dynamic value = map[key];
  if (value is String) {
    return value.parse<T>();
  }
  return value is T ? value : (throw ValidationException('The value of key $key is not a $T', requiredType));
}

T notNull<T>(Map<String, dynamic> map, String key, [T? defaultValue]) {
  final dynamic value = map[key];
  if (value == null) {
    if (defaultValue != null) return defaultValue;
    throw ValidationException('The key $key is null in map $map', notNull);
  }
  return requiredType<T>(map, key);
}

T notEmpty<T>(Map<String, dynamic> map, String key) {
  final dynamic value = map[key];
  final throwable = ValidationException('The key $key is empty in map $map', notEmpty);
  return switch (value) { String val => val.isEmpty ? throw throwable : notNull<T>(map, key), Iterable val => val.isEmpty ? throw throwable : notNull<T>(map, key), Map val => val.isEmpty ? throw throwable : notNull<T>(map, key), _ => notNull<T>(map, key) };
}
