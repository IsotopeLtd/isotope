import 'package:flutter/material.dart';
import 'package:isotope/src/responsive/responsive_device.dart';

/// Contains sizing information to make responsive choices for the current screen.
class ScreenInfo {
  final ResponsiveDevice responsiveDevice;
  final Size widgetSize;
  final Size screenSize;

  bool get isDesktop => responsiveDevice == ResponsiveDevice.Desktop;
  bool get isMobile => responsiveDevice == ResponsiveDevice.Mobile;
  bool get isTablet => responsiveDevice == ResponsiveDevice.Tablet;
  bool get isWatch => responsiveDevice == ResponsiveDevice.Watch;

  ScreenInfo({
    this.responsiveDevice,
    this.screenSize,
    this.widgetSize,
  });

  @override
  String toString() {
    return 'responsiveDevice:$responsiveDevice screenSize:$screenSize widgetSize:$widgetSize';
  }
}
