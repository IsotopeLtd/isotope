class Localization {
  static const String assetManifestFilename = 'AssetManifest.json';
  static const String localizedAssetsPath = 'assets/i18n';
  static const String pluralZero = '0';
  static const String pluralOne = '1';
  static const String pluralTwo = '2';
  static const String pluralElse = 'else';
  static const String pluralValueArg = '{{value}}';

  Map<dynamic, dynamic> _translations;
  Map<dynamic, dynamic> _fallbackTranslations;

  Localization._();

  static Localization _instance;
  static Localization get instance => _instance ?? (_instance = Localization._());

  static void load(Map<dynamic, dynamic> translations, {Map<dynamic, dynamic> fallback}) {
    instance._translations = translations;
    instance._fallbackTranslations = fallback;
  }

  String translate(String key, {Map<String, dynamic> args}) {
    String translation = _getTranslation(key, _translations, _fallbackTranslations);
    if (translation != null && args != null) {
      translation = _assignArguments(translation, args);
    }
    return translation ?? key;
  }

  String plural(String key, num value, {Map<String, dynamic> args}) {
    String pluralKeyValue = _getPluralKeyValue(value);
    String translation = _getPluralTranslation(key, pluralKeyValue, _translations);
    if (translation != null) {
      translation = translation.replaceAll(Localization.pluralValueArg, value.toString());
      if (args != null) {
        translation = _assignArguments(translation, args);
      }
    }
    return translation ?? '$key.$pluralKeyValue';
  }

  String _getPluralKeyValue(num value) {
    switch (value) {
      case 0: return Localization.pluralZero;
      case 1: return Localization.pluralOne;
      case 2: return Localization.pluralTwo;
      default: return Localization.pluralElse;
    }
  }

  String _assignArguments(String value, Map<String, dynamic> args) {
    for (final key in args.keys) {
      value = value.replaceAll('{$key}', '${args[key]}');
    }
    return value;
  }

  String _getTranslation(String key, Map<String, dynamic> map, Map<String, dynamic> fallbackMap) {
    List<String> keys = key.split('.');
    if (keys.length > 1) {
      String firstKey = keys.first;
      String remainingKey = key.substring(key.indexOf('.') + 1);
      var value = map[firstKey];
      if (value != null && value is! String) {
        return _getTranslation(remainingKey, value, fallbackMap != null ? fallbackMap[firstKey] : null);
      } else if (fallbackMap != null) {
        var fallbackValue = fallbackMap[firstKey];
        if (fallbackValue != null && fallbackValue is! String) {
          return _getTranslation(remainingKey, fallbackValue, null);
        }
      }
    }
    return map[key] ?? (fallbackMap != null ? fallbackMap[key] : null);
  }

  String _getPluralTranslation(String key, String valueKey, Map<String, dynamic> map) {
    List<String> keys = key.split('.');
    if (keys.length > 1) {
      String firstKey = keys.first;
      if (map.containsKey(firstKey) && map[firstKey] is! String) {
        return _getPluralTranslation(key.substring(key.indexOf('.') + 1), valueKey, map[firstKey]);
      }
    }
    return map[key][valueKey] ?? map[key][Localization.pluralElse];
  }
}
