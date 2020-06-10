import 'dart:convert';
import 'dart:ui';
import 'package:isotope/src/localization/locale_file_service.dart';
import 'package:isotope/src/localization/localization_global.dart';

class LocaleService {
  static Future<Map<Locale, String>> getLocalesMap(List<String> locales, String basePath) async {
    Map<String, String> files = await LocaleFileService.getLocaleFiles(locales, basePath);
    return files.map((x,y) => MapEntry(localeFromString(x), y));
  }

  static Locale findLocale(Locale locale, List<Locale> supportedLocales) {
    var existing = supportedLocales.firstWhere((x) => x == locale, orElse: () => null);
    if (existing == null) {
      existing = supportedLocales.firstWhere((x) => x.languageCode == locale.languageCode, orElse: () => null);
    }
    return existing;
  }

  static Future<Map<String, dynamic>> getLocaleContent(Locale locale, Map<Locale, String> supportedLocales) async {
    String file = supportedLocales[locale];
    String content = await LocaleFileService.getLocaleContent(file);
    return json.decode(content);
  }
}
