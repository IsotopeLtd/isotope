import 'dart:ui';

abstract class LocalizationPreferences {
  Future savePreferredLocale(Locale locale);
  Future<Locale> getPreferredLocale();
}
