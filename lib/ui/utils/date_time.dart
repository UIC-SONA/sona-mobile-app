/// The list of days in a given month
List<DateTime> daysInMonth(DateTime month) {
  var first = firstDayOfMonth(month);
  var daysBefore = first.weekday;
  var firstToDisplay = first.subtract(Duration(days: daysBefore));
  var last = lastDayOfMonth(month);

  var daysAfter = 7 - last.weekday;

  if (daysAfter == 0) {
    daysAfter = 7;
  }

  var lastToDisplay = last.add(Duration(days: daysAfter));
  return daysInRange(firstToDisplay, lastToDisplay).toList();
}

bool isFirstDayOfMonth(DateTime day) {
  return isSameDay(firstDayOfMonth(day), day);
}

bool isLastDayOfMonth(DateTime day) {
  return isSameDay(lastDayOfMonth(day), day);
}

DateTime firstDayOfMonth(DateTime month) {
  return DateTime(month.year, month.month);
}

DateTime firstDayOfWeek(DateTime day) {
  /// Handle Daylight Savings by setting hour to 12:00 Noon
  /// rather than the default of Midnight
  day = DateTime.utc(day.year, day.month, day.day, 12);

  /// Weekday is on a 1-7 scale Monday - Sunday,
  /// This Calendar works from Sunday - Monday
  var decreaseNum = day.weekday % 7;
  return day.subtract(Duration(days: decreaseNum));
}

DateTime lastDayOfWeek(DateTime day) {
  /// Handle Daylight Savings by setting hour to 12:00 Noon
  /// rather than the default of Midnight
  day = DateTime.utc(day.year, day.month, day.day, 12);

  /// Weekday is on a 1-7 scale Monday - Sunday,
  /// This Calendar's Week starts on Sunday
  var increaseNum = day.weekday % 7;
  return day.add(Duration(days: 7 - increaseNum));
}

/// The last day of a given month
DateTime lastDayOfMonth(DateTime month) {
  var beginningNextMonth = (month.month < 12) ? DateTime(month.year, month.month + 1, 1) : DateTime(month.year + 1, 1, 1);
  return beginningNextMonth.subtract(const Duration(days: 1));
}

/// Returns a [DateTime] for each day the given range.
///
/// [start] inclusive
/// [end] exclusive
Iterable<DateTime> daysInRange(DateTime start, DateTime end) sync* {
  var i = start;
  var offset = start.timeZoneOffset;
  while (i.isBefore(end)) {
    yield i;
    i = i.add(const Duration(days: 1));
    var timeZoneDiff = i.timeZoneOffset - offset;
    if (timeZoneDiff.inSeconds != 0) {
      offset = i.timeZoneOffset;
      i = i.subtract(Duration(seconds: timeZoneDiff.inSeconds));
    }
  }
}

/// Whether or not two times are on the same day.
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isSameWeek(DateTime a, DateTime b) {
  /// Handle Daylight Savings by setting hour to 12:00 Noon
  /// rather than the default of Midnight
  a = DateTime.utc(a.year, a.month, a.day);
  b = DateTime.utc(b.year, b.month, b.day);

  var diff = a.toUtc().difference(b.toUtc()).inDays;
  if (diff.abs() >= 7) {
    return false;
  }

  var min = a.isBefore(b) ? a : b;
  var max = a.isBefore(b) ? b : a;
  var result = max.weekday % 7 - min.weekday % 7 >= 0;
  return result;
}

DateTime previousMonth(DateTime m) {
  var year = m.year;
  var month = m.month;
  if (month == 1) {
    year--;
    month = 12;
  } else {
    month--;
  }
  return DateTime(year, month);
}

DateTime nextMonth(DateTime m) {
  var year = m.year;
  var month = m.month;

  if (month == 12) {
    year++;
    month = 1;
  } else {
    month++;
  }
  return DateTime(year, month);
}

DateTime previousWeek(DateTime w) {
  return w.subtract(const Duration(days: 7));
}

DateTime nextWeek(DateTime w) {
  return w.add(const Duration(days: 7));
}

DateTime getDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
