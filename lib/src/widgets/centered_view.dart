import 'package:flutter/material.dart';

class CenteredView extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredView({Key key, this.child, this.maxWidth = 1200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 60),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
