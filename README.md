# Isotope

A package of architecture libraries for modern Flutter applications.

## Installation

Add the following dependencies to your `pubspec.yaml`:

```dart
dependences:
  isotope:
    git: git://github.com/IsotopeVentures/isotope.git
```

## Implementation

If you want to import the entire package (not recommended, it's quite large); in your project, import the package:

```dart
import 'package:isotope/isotope';
```

Alternatively, import just the libraries you're interested in:

```dart
import 'package:isotope/extensions.dart';
import 'package:isotope/formatters.dart';
import 'package:isotope/forms.dart';
import 'package:isotope/localization.dart';
import 'package:isotope/models.dart';
import 'package:isotope/notifier.dart';
import 'package:isotope/platform.dart';
import 'package:isotope/presenters.dart';
import 'package:isotope/reactive.dart';
import 'package:isotope/registrar.dart';
import 'package:isotope/services.dart';
import 'package:isotope/utilities.dart';
import 'package:isotope/views.dart';
import 'package:isotope/widgets.dart';
```

## License

This library is available as open source under the terms of the MIT License.

## Copyright

Copyright © 2020 Jurgen Jocubeit & Isotope Ventures Pty Ltd.
All rights reserved.
