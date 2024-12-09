import 'dart:io';
import 'package:intl/intl.dart';

typedef MapperIndexed<T, R> = R Function(T element, int index);
typedef Mapper<T, R> = R Function(T element);

extension IterableExtension<T> on Iterable<T> {
  //
  Iterable<R> mapListNumbered<R>(MapperIndexed<T, R> toElement) {
    int index = 0;
    return map((element) => toElement(element, index++));
  }

  //
  List<R> mapList<R>(Mapper<T, R> toElement) => map(toElement).toList();
}

class ParseStringException implements Exception {
  final String message;
  final String string;
  final Type targetType;

  ParseStringException(this.targetType, this.string) : message = "Error parsing body $string to Type $targetType";
}

class FromString<T> {
  late final Type type;
  final T Function(String data) parse;

  FromString(this.parse) : type = T;
}

extension StringExtension on String {
  //
  String truncate([int maxLength = 1000]) {
    return length > maxLength ? '${substring(0, maxLength)}...' : this;
  }

  static List<FromString> get fromStringConverters => [
        FromString<String>((data) => data),
        FromString<String?>((data) => data),
        FromString<num>(num.parse),
        FromString<num?>(num.tryParse),
        FromString<int>(int.parse),
        FromString<int?>(int.tryParse),
        FromString<double>(double.parse),
        FromString<double?>(double.tryParse),
        FromString<bool>(bool.parse),
        FromString<bool?>(bool.tryParse),
        FromString<DateTime>(DateTime.parse),
        FromString<DateTime?>(DateTime.tryParse),
        FromString<Uri>(Uri.parse),
        FromString<Uri?>(Uri.tryParse),
        FromString<BigInt>(BigInt.parse),
        FromString<BigInt?>(BigInt.tryParse),
        FromString<InternetAddress>((value) => InternetAddress(value)),
        FromString<InternetAddress?>((value) => InternetAddress.tryParse(value)),
      ];

  static bool supportParse(Type type) => fromStringConverters.any((element) => element.type == type);

  T parse<T>() => _internalParse<T, T>();

  R _internalParse<T, R>() {
    final fromString = fromStringConverters.where((element) => element.type == T).firstOrNull;
    if (fromString != null) {
      return fromString.parse(this) as R;
    }
    throw ParseStringException(T, this);
  }

  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}

extension NumExtension on num {
  bool get isInt => this is int;

  bool get isDouble => this is double;

  bool get isPositive => this > 0;

  bool get isNegative => this < 0;

  bool get isZero => this == 0;

  bool get isNotZero => this != 0;

  bool get isEven => this % 2 == 0;

  bool get isOdd => this % 2 != 0;

  bool get isPrime {
    if (this <= 1) return false;
    if (this <= 3) return true;
    if (this % 2 == 0 || this % 3 == 0) return false;
    for (int i = 5; i * i <= this; i += 6) {
      if (this % i == 0 || this % (i + 2) == 0) return false;
    }
    return true;
  }

  int get factorial {
    if (this < 0) return -1;
    if (this == 0) return 1;
    int result = 1;
    for (int i = 1; i <= this; i++) {
      result *= i;
    }
    return result;
  }

  int get fibonacci {
    if (this < 0) return -1;
    if (this <= 1) return toInt();
    int n1 = 0, n2 = 1, n = 0;
    for (int i = 2; i <= this; i++) {
      n = n1 + n2;
      n1 = n2;
      n2 = n;
    }
    return n;
  }

  int get nextPrime {
    int n = toInt() + 1;
    while (!n.isPrime) {
      n++;
    }
    return n;
  }

  int get previousPrime {
    int n = toInt() - 1;
    while (!n.isPrime) {
      n--;
    }

    return n;
  }

  int get nextOdd {
    int n = toInt() + 1;
    return n.isOdd ? n : n + 1;
  }

  int get previousOdd {
    int n = toInt() - 1;
    return n.isOdd ? n : n - 1;
  }

  int get nextEven {
    int n = toInt() + 1;
    return n.isEven ? n : n + 1;
  }

  int get previousEven {
    int n = toInt() - 1;
    return n.isEven ? n : n - 1;
  }

  num get abs => this < 0 ? -this : this;

  num pow(int exponent) {
    if (exponent == 0) return 1;
    if (exponent == 1) return this;
    return this * pow(exponent - 1);
  }

  double roundTo(int decimalPlaces) {
    num mod = 10.0.pow(decimalPlaces);
    return (this * mod).round().toDouble() / mod;
  }
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.year == year && yesterday.month == month && yesterday.day == day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.year == year && tomorrow.month == month && tomorrow.day == day;
  }

  bool get isThisYear => DateTime.now().year == year;

  bool get isThisMonth => DateTime.now().month == month;

  bool get isThisWeek {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 7));
    return isAfter(firstDayOfWeek) && isBefore(lastDayOfWeek);
  }

  bool get isLastWeek {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 7));
    final firstDayOfLastWeek = firstDayOfWeek.subtract(const Duration(days: 7));
    final lastDayOfLastWeek = lastDayOfWeek.subtract(const Duration(days: 7));
    return isAfter(firstDayOfLastWeek) && isBefore(lastDayOfLastWeek);
  }

  bool get isNextWeek {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 7));
    final firstDayOfNextWeek = firstDayOfWeek.add(const Duration(days: 7));
    final lastDayOfNextWeek = lastDayOfWeek.add(const Duration(days: 7));
    return isAfter(firstDayOfNextWeek) && isBefore(lastDayOfNextWeek);
  }

  bool get isWeekend {
    final weekday = this.weekday;
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  bool get isWeekday => !isWeekend;

  String format([DateTimeFormat format = DateTimeFormat.dateTime]) {
    return DateFormat(format.pattern).format(this);
  }
}

enum DateTimeFormat {
  dateTime("yyyy-MM-dd HH:mm:ss"),
  date("yyyy-MM-dd"),
  dateHourMinute("yyyy-MM-dd HH:mm"),
  dateHour("yyyy-MM-dd HH"),
  time("HH:mm:ss"),
  year("yyyy"),
  month("MM"),
  day("dd"),
  hour("HH"),
  minute("mm"),
  second("ss");

  final String pattern;

  const DateTimeFormat(this.pattern);
}

extension EnumExtension on Enum {
  String get javaName => name
      .replaceAllMapped(
        RegExp(r'(?<=[a-z])([A-Z])'), // Detecta transiciones de minúscula a mayúscula.
        (match) => '_${match.group(0)}', // Inserta un guión bajo antes de la mayúscula.
      )
      .toUpperCase();
}
