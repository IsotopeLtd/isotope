# Isotope Localization

Localization is a fully featured localization / internationalization (i18n) library for Flutter. It permits definition of localizations for your content in different languages and the ability switch between them easily.

## Features

* ```Mobile``` & ```Web``` support
* ```Pluralization``` and ```Duals``` support 
* Supports both ``languageCode (en)`` and ``languageCode_countryCode (en_US)`` locale formats 
* Automatically ```save & restore``` the selected locale
* Full support for ```right-to-left``` locales
* ``Fallback`` locale support in case the system locale is supported
* Supports both ``inline or nested`` JSON


## Installation

Add the following to your `pubspec.yaml`:

```dart
dependencies:
  flutter_localizations:
    sdk: flutter
  isotope:
    git: git://github.com/IsotopeLtd/isotope.git
    version: 1.0.0

flutter:
  assets: 
    - assets/i18n/
```

## Implementation

Import the forms library in your `main.dart` entry source and create a `LocalizationDelegate`.
Wrap the delegate in a `LocalizedApp` widget along with your root widget (e.g. MyApp):

```dart
import 'package:flutter/material.dart';
import 'package:isotope/localization.dart';

void main() async {
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_US',
    supportedLocales: ['en_US']
  );
  runApp(LocalizedApp(delegate, MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LocalizationDelegate localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: i18n('app_title'),
        home: HomeScreen(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
      ),
    ),
  },
}
```

Add an `en.json` file in the `assets/i18n` and add some keys:

```json
{
  "app_title": "Treasury"
}
```

### Localization

The convenience method `i18n` will accept the key to localize and an optional integer plurality.

Consider the following nested localizations keys and values:

```json
{
  "terms": {
    "project": { 
      "0": "Projects",
      "1": "Project", 
      "2": "Projects",
      "else": "All Projects" 
    }
  }
}
```

In order the access the singular localization, call the following:

```dart
String term = i18n('terms.project'); // "Project"
// or
String term = i18n('terms.project', Localization.pluralOne); // "Project"
```

To localize the plural:

```dart
String term = i18n('terms.project', Localization.pluralTwo); // "Projects"
```

If the term uses a plural localization for zero, then you call call:

```dart
String term = i18n('terms.project', Localization.pluralZero); // "Projects"
```

If more than two of something might result in a different localization:

```dart
String term = i18n('terms.project', Localization.pluralElse); // "All Projects"
```

### Localization Interpolation

***TBA*** This is supported but requires documentation (e.g. Localization.pluralValueArg).

### Fallback Locale

***TBA*** This is supported but requires documentation.

## License

This library is available as open source under the terms of the MIT License.

## Copyright

Copyright © 2020 Jurgen Jocubeit
