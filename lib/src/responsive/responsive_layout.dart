import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isotope/src/responsive/responsive_breakpoints.dart';
import 'package:isotope/src/responsive/responsive_builder.dart';
import 'package:isotope/src/responsive/responsive_device.dart';

typedef WidgetBuilder = Widget Function(BuildContext);

/// Provides a builder function for different screen types.
///
/// Each builder will get built based on the current device width.
/// [breakpoints] define your own custom device resolutions
/// [watch] will be built and shown when width is less than 300
/// [mobile] will be built when width greater than 300
/// [tablet] will be built when width is greater than 600
/// [desktop] will be built if width is greater than 950
class ResponsiveLayout extends StatelessWidget {
  final ResponsiveBreakpoints breakpoints;
  final WidgetBuilder watch;
  final WidgetBuilder mobile;
  final WidgetBuilder tablet;
  final WidgetBuilder desktop;

  ResponsiveLayout(
      {Key key, this.breakpoints, Widget watch, Widget mobile, Widget tablet, Widget desktop}) :
      this.watch = _builderOrNull(watch),
      this.mobile = _builderOrNull(mobile),
      this.tablet = _builderOrNull(tablet),
      this.desktop = _builderOrNull(desktop),
      super(key: key);

  const ResponsiveLayout.builder(
      {Key key, this.breakpoints, this.watch, this.mobile, this.tablet, this.desktop})
      : super(key: key);

  static WidgetBuilder _builderOrNull(Widget widget) {
    return widget == null ? null : ((_) => widget);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, screenInfo) {
        // If we're at desktop size:
        if (screenInfo.responsiveDevice == ResponsiveDevice.Desktop) {
          // If we have supplied the desktop layout then display that:
          if (desktop != null) return desktop(context);

          // If no desktop layout is supplied we want to check if we have 
          // the size below it and display that:
          if (tablet != null) return tablet(context);
        }

        if (screenInfo.responsiveDevice == ResponsiveDevice.Tablet) {
          if (tablet != null) return tablet(context);
        }

        if (screenInfo.responsiveDevice == ResponsiveDevice.Watch &&
            watch != null) {
          return watch(context);
        }

        // If none of the layouts above are supplied or we're on the mobile 
        // layout then we show the mobile layout:
        return mobile(context);
      },
    );
  }
}
