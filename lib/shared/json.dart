import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:sona/shared/validation/map_validations.dart';

typedef FromJson<T> = T Function(dynamic json);
typedef ToJson<T> = dynamic Function(T value);
typedef FromJsonMap<T> = T Function(Map<String, dynamic> json);
typedef ToJsonMap<T> = Map<String, dynamic> Function(T value);

abstract final class Json {
  /// METHOD TO SERIALIZE AND DESERIALIZE A VALUE

  /// [serialize] takes a value and returns a String with the JSON representation of the value
  /// registered with [register] for the type [T] or the default serialization if the type is a Map or List<Map>
  ///
  /// Examples:
  ///
  /// ```dart
  /// final String json = Json.serialize<Model>(Model('name', 20));
  /// ```
  /// or
  /// ```dart
  /// final String json = Json.serialize<List<Model>>([Model('name', 20), Model('name2', 21)]);
  /// ```
  ///
  static String serialize<T>(T value) {
    if (value is Map || value is List<Map>) return jsonEncode(value);
    final _JsonCodec<T> codec = _JsonCodec.get<T>();
    return jsonEncode(codec.toJson(value));
  }

  /// [deserialize] takes a String with a JSON representation of a value and returns an instance of T
  /// registered with [register] for the type [T] or the default deserialization if the type is a Map or List<Map>
  ///
  /// Examples:
  ///
  /// ```dart
  /// final Model model = Json.deserialize<Model>('{"name": "name", "age": 20}');
  /// ```
  ///
  /// or
  /// ```dart
  /// final Model models = Json.deserialize<List<Model>>([{"name": "name", "age": 20}, {"name": "name2", "age": 21}]);
  /// ```
  ///
  static T deserialize<T>(String json) {
    return deserializeDecoded<T>(jsonDecode(json));
  }

  static T deserializeDecoded<T>(dynamic json) {
    final decoded = jsonDecode(json);
    if (T == Map || T == List<Map>) return decoded as T;
    return _JsonCodec.get<T>().fromJson(decoded);
  }

  /// METHOD TO REGISTER SERIALIZATION AND DESERIALIZATION FOR A TYPE

  /// [fromJson] is a function that takes a [Map<String, dynamic>] and returns an instance of T
  /// [toJson] is a function that takes an instance of T and returns a Map<String, dynamic>
  ///
  /// Examples:
  ///
  /// ```dart
  /// Json.register<Model>(
  ///   fromJson: (Map<String, dynamic> json) => Model.fromJson(json),
  ///   toJson: (Model value) => value.toJson(),
  /// );
  ///  ```
  ///  or
  ///  ```dart
  ///  Json.register<Model>(
  ///   fromJson: Model.fromJson,
  ///   toJson: (Model value) => value.toJson(),
  ///  );
  ///  ```
  ///  or
  ///
  ///  ```dart
  ///  Json.register<Model>(
  ///   fromJson: (Map<String, dynamic> json)
  ///     return Model(
  ///       json["name"],
  ///       json["age"],
  ///     ),
  ///     toJson: (Model value) => {
  ///       'name': value.name,
  ///       'age': value.age
  ///     },
  ///   );
  ///   ```
  ///   NOTE:
  ///   If the type is a List, the type of the elements is inferred from the type of the List
  static void register<T>({required FromJsonMap<T> fromJson, required ToJsonMap<T> toJson}) => _JsonCodec.register<T>(fromJsonMap: fromJson, toJsonMap: toJson);

  static void registerDefaultsCodecs() {
    register<Color>(
      fromJson: (Map<String, dynamic> json) => Color.fromARGB(
        notNull<int>(json, 'alpha'),
        notNull<int>(json, 'red'),
        notNull<int>(json, 'green'),
        notNull<int>(json, 'blue'),
      ),
      toJson: (Color value) => {
        'alpha': value.alpha,
        'red': value.red,
        'green': value.green,
        'blue': value.blue,
      },
    );

    register<Offset>(
      fromJson: (Map<String, dynamic> json) => Offset(
        notNull<double>(json, 'dx'),
        notNull<double>(json, 'dy'),
      ),
      toJson: (Offset value) => {
        'dx': value.dx,
        'dy': value.dy,
      },
    );

    register<Size>(
      fromJson: (Map<String, dynamic> json) => Size(
        notNull<double>(json, 'width'),
        notNull<double>(json, 'height'),
      ),
      toJson: (Size value) => {
        'width': value.width,
        'height': value.height,
      },
    );

    register<Rect>(
      fromJson: (Map<String, dynamic> json) => Rect.fromLTWH(
        notNull<double>(json, 'left', 0),
        notNull<double>(json, 'top', 0),
        notNull<double>(json, 'width', 0),
        notNull<double>(json, 'height', 0),
      ),
      toJson: (Rect value) => {
        'left': value.left,
        'top': value.top,
        'width': value.width,
        'height': value.height,
      },
    );

    register<EdgeInsets>(
      fromJson: (Map<String, dynamic> json) => EdgeInsets.only(
        top: notNull<double>(json, 'top', 0),
        bottom: notNull<double>(json, 'bottom', 0),
        left: notNull<double>(json, 'left', 0),
        right: notNull<double>(json, 'right', 0),
      ),
      toJson: (EdgeInsets value) => {
        'top': value.top,
        'bottom': value.bottom,
        'left': value.left,
        'right': value.right,
      },
    );

    register<Duration>(
      fromJson: (Map<String, dynamic> json) => Duration(
        days: notNull<int>(json, 'days', 0),
        hours: notNull<int>(json, 'hours', 0),
        minutes: notNull<int>(json, 'minutes', 0),
        seconds: notNull<int>(json, 'seconds', 0),
        milliseconds: notNull<int>(json, 'milliseconds', 0),
        microseconds: notNull<int>(json, 'microseconds', 0),
      ),
      toJson: (Duration value) => {
        'days': value.inDays,
        'hours': value.inHours,
        'minutes': value.inMinutes,
        'seconds': value.inSeconds,
        'milliseconds': value.inMilliseconds,
        'microseconds': value.inMicroseconds,
      },
    );
  }

  @override
  String toString() {
    var result = 'Json\n';
    result += 'Registered types:\n';
    for (final codec in _JsonCodec.coders) {
      result += ' ♠ ${codec.targetType}\n';
    }
    return result;
  }
}

class _JsonCodec<T> {
  static final List<_JsonCodec> coders = <_JsonCodec>[];
  final FromJson<T> fromJson;
  final ToJson<T> toJson;

  _JsonCodec(this.fromJson, this.toJson);

  static _JsonCodec<T> get<T>() => getFromType(T) as _JsonCodec<T>;

  static _JsonCodec getFromType(Type type) {
    return coders.firstWhere(
      (element) => element.targetType == type,
      orElse: () => throw JsonCodecException('Type $type not registered', type),
    );
  }

  static void register<T>({required FromJsonMap<T> fromJsonMap, required ToJsonMap<T> toJsonMap}) {
    if (T == dynamic) {
      throw JsonCodecException('Type dynamic not supported for serialization', T);
    }

    if (T == List) {
      throw JsonCodecException('Type List not supported for serialization', T);
    }

    if (coders.any((element) => element.isType(T))) {
      throw JsonCodecException('Type $T already registered', T);
    }

    T fromJsonObject(dynamic json) => fromJsonMap(json as Map<String, dynamic>);
    Map<String, dynamic> toJsonObject(T value) => toJsonMap(value);

    List<T> fromJsonArray(dynamic json) => (json as List).map(fromJsonObject).toList();
    List<Map<String, dynamic>> toJsonArray(List<T> value) => value.map(toJsonObject).toList();

    coders.add(_JsonCodec<T>(fromJsonObject, toJsonObject));
    coders.add(_JsonCodec<List<T>>(fromJsonArray, toJsonArray));
  }

  bool isType(Type type) => targetType == type;

  Type get targetType => T;

  @override
  String toString() => 'JsonCodec<$T>';
}

class JsonCodecException implements Exception {
  final String message;
  final Type targetType;

  JsonCodecException(this.message, this.targetType);

  @override
  String toString() => 'JsonCodecException: $message for type $targetType';
}
