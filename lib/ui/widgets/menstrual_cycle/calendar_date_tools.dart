import 'dart:ui';

import 'package:intl/intl.dart';

class CalenderDateFormatter {
  final Locale locale;
  final DateFormat _monthFormat;
  final DateFormat _dayFormat;
  final DateFormat _dayMonth;
  final DateFormat _firstDayFormat;
  final DateFormat _fullDayFormat;
  final DateFormat _fullDayName;
  final DateFormat _dateFormat;
  final DateFormat _yearFormat;
  final DateFormat _calendarFotterFormat;
  final List<String> weekTitles;

  CalenderDateFormatter(this.locale)
      : _monthFormat = DateFormat('MMMM yyyy', locale.toString()),
        _dayFormat = DateFormat('dd', locale.toString()),
        _dayMonth = DateFormat('dd MMMM', locale.toString()),
        _firstDayFormat = DateFormat('MMM dd', locale.toString()),
        _fullDayFormat = DateFormat('EEE MMM dd, yyyy', locale.toString()),
        _fullDayName = DateFormat('EEEE', locale.toString()),
        _dateFormat = DateFormat('yyyy-MM-dd', locale.toString()),
        _yearFormat = DateFormat('yyyy', locale.toString()),
        _calendarFotterFormat = DateFormat("EEEE dd MMMM, yyyy", locale.toString()),
        weekTitles = _generateWeekTitles(locale);

  static List<String> _generateWeekTitles(Locale locale) {
    final DateTime startOfWeek = DateTime(2024, 1, 7); // Domingo
    return List.generate(
      7,
          (index) => _capitalizeWords(
          DateFormat('EEE', locale.toString()).format(startOfWeek.add(Duration(days: index))),
          locale),
    );
  }

  String formatYear(DateTime d) => _yearFormat.format(d);

  String formatMonthYear(DateTime d) => _capitalizeWords(_monthFormat.format(d), locale);

  String fullDayName(DateTime d) => _capitalizeWords(_fullDayName.format(d), locale);

  String formatDayMonth(DateTime d) => _capitalizeWords(_dayMonth.format(d), locale);

  String formatDay(DateTime d) => _dayFormat.format(d);

  String formatFirstDay(DateTime d) => _firstDayFormat.format(d);

  String fullDayFormat(DateTime d) => _fullDayFormat.format(d);

  String dateDayFormat(DateTime d) => _dateFormat.format(d);

  String calendarFooterFormat(DateTime d) => _capitalizeWords(_calendarFotterFormat.format(d), locale);

  String getWeekTitle(int index) => weekTitles[index];

  static String _capitalizeWords(String text, Locale locale) {
    // Divide el texto en palabras y capitaliza la primera letra de cada palabra
    final words = text.split(' ');
    return words.map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1)}';
      }
      return word;
    }).join(' ');
  }
}

