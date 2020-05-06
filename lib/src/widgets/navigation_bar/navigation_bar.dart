import 'package:flutter/material.dart';
import 'package:isotope/views.dart';
import 'package:isotope/src/widgets/navigation_bar/navigation_bar_tablet_desktop.dart';
import 'package:isotope/src/widgets/navigation_bar/navigation_bar_mobile.dart';

class NavigationBar extends StatelessWidget {
  const NavigationBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: NavigationBarMobile(),
      tablet: NavigationBarTabletDesktop(),
    );
  }
}
