import 'package:flutter/material.dart';

class NavigationDrawerHeader extends StatelessWidget {
  final Color primaryColor;

  const NavigationDrawerHeader({Color this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: primaryColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Asset',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w800, 
              color: Colors.white
            ),
          ),
          Text(
            'Studio',
            style: TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
