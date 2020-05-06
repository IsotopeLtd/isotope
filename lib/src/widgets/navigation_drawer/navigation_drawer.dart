import 'package:flutter/material.dart';

class NavigationDrawer extends StatelessWidget {
  final List<Widget> items;

  const NavigationDrawer({this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 16),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }
}
