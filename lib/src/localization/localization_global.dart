import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:isotope/src/localization/localization.dart';
import 'package:isotope/src/localization/localization_provider.dart';
import 'package:isotope/src/localization/localized_app.dart';

typedef LocaleChangedCallback = Future Function(Locale locale);

Locale localeFromString(String code, {bool languageCodeOnly = false}) {
	if (code.contains('_')) {
		List<String> parts = code.split('_');
		return languageCodeOnly ? Locale(parts[0]) : Locale(parts[0], parts[1]);
	} else {
		return Locale(code);
	}
}

String localeToString(Locale locale) {
	return locale.countryCode != null ? '${locale.languageCode}_${locale.countryCode}' : locale.languageCode;
}

String i18n(String key, [int plurality = 1]) {
  if (plurality == 1) {
    return translate(key);
  } else {
    return translatePlural(key, plurality);
  }
}

String translate(String key, {Map<String, dynamic> args}) {
	return Localization.instance.translate(key, args: args);
}

String translatePlural(String key, num value, {Map<String, dynamic> args}) {
	return Localization.instance.plural(key, value, args: args);
}

Future changeLocale(BuildContext context, String localeCode) async {
	if (localeCode != null) {
		await LocalizedApp.of(context).delegate.changeLocale(localeFromString(localeCode));
		LocalizationProvider.of(context).state.onLocaleChanged();
	}
}
