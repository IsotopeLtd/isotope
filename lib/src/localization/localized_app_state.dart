import 'package:flutter/widgets.dart';
import 'package:isotope/src/localization/localized_app.dart';
import 'package:isotope/src/localization/localization_provider.dart';

class LocalizedAppState extends State<LocalizedApp> {
  void onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) => LocalizationProvider(state: this, child: widget.child);
}
