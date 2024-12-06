import 'package:intl/intl.dart';

abstract class LocaleProvider {
  String get locale;

  String get languageCode;

  set locale(String locale);
}

class SystemLocaleProvider implements LocaleProvider {
  @override
  String get locale => Intl.getCurrentLocale();

  @override
  String get languageCode => locale.split('_').first;

  @override
  set locale(String locale) {
    Intl.defaultLocale = locale;
  }
}
