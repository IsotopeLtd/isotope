import 'package:flutter/material.dart';

class NavigationBarTabletDesktop extends StatelessWidget {
  final List<Widget> items;

  const NavigationBarTabletDesktop({this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items,
      ),
    );
  }
}
