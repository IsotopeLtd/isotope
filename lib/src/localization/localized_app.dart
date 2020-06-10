import 'package:flutter/widgets.dart';
import 'package:isotope/src/localization/localization_delegate.dart';
import 'package:isotope/src/localization/localized_app_state.dart';

class LocalizedApp extends StatefulWidget {
  final Widget child;
  final LocalizationDelegate delegate;

  LocalizedApp(this.delegate, this.child);
  LocalizedAppState createState() => LocalizedAppState();

  static LocalizedApp of(BuildContext context) => context.findAncestorWidgetOfExactType<LocalizedApp>();
}
