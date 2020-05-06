import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isotope/src/responsive/responsive_breakpoints.dart';
import 'package:isotope/src/responsive/responsive_device.dart';
import 'package:isotope/src/responsive/screen_info.dart';

/// A widget with a builder that provides you with the sizingInformation.
/// This widget is used by the ViewportWidget to provide different widget builders.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ScreenInfo screenInfo,
  ) builder;

  final ResponsiveBreakpoints breakpoints;

  const ResponsiveBuilder({
    Key key,
    this.builder,
    this.breakpoints
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      var mediaQuery = MediaQuery.of(context);
      var screenInfo = ScreenInfo(
        responsiveDevice: _getResponsiveDevice(mediaQuery, breakpoints),
        screenSize: mediaQuery.size,
        widgetSize: Size(boxConstraints.maxWidth, boxConstraints.maxHeight),
      );
      return builder(context, screenInfo);
    });
  }
}

ResponsiveDevice _getResponsiveDevice(MediaQueryData mediaQueryData, ResponsiveBreakpoints responsiveBreakpoint) {
  double deviceWidth = mediaQueryData.size.shortestSide;

  if (kIsWeb) {
    deviceWidth = mediaQueryData.size.width;
  }

  // Replaces the defaults with user-defined definitions.
  if(responsiveBreakpoint != null) {
    if(deviceWidth > responsiveBreakpoint.desktop) {
      return ResponsiveDevice.Desktop;
    }

    if(deviceWidth > responsiveBreakpoint.tablet) {
      return ResponsiveDevice.Tablet;
    }

    if(deviceWidth < responsiveBreakpoint.watch) {
      return ResponsiveDevice.Watch;
    }
  }

  // If no user-defined definitions are passed through use the defaults.
  if (deviceWidth > 950) {
    return ResponsiveDevice.Desktop;
  }

  if (deviceWidth > 600) {
    return ResponsiveDevice.Tablet;
  }

  if (deviceWidth < 300) {
    return ResponsiveDevice.Watch;
  }

  return ResponsiveDevice.Mobile;   
}
