import 'package:flutter/foundation.dart';

/// Manually define screen resolution breakpoints. Overrides the defaults.
class ResponsiveBreakpoints {
  final double desktop;
  final double tablet;
  final double watch;

  ResponsiveBreakpoints({
    @required this.desktop,
    @required this.tablet,
    @required this.watch
  });

  @override
  String toString() {
    return "Desktop: $desktop, Tablet: $tablet, Watch: $watch";
  }
}
