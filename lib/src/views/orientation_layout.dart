import 'package:flutter/material.dart';

/// Provides a landscape and portrait widget.
class OrientationLayout extends StatelessWidget {
  final WidgetBuilder landscape;
  final WidgetBuilder portrait;

  const OrientationLayout({
    Key key,
    this.landscape,
    this.portrait,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        var orientation = MediaQuery.of(context).orientation;
        if (orientation == Orientation.landscape) {
          if (landscape != null) {
            return landscape(context);
          }
        }

        return portrait(context);
      },
    );
  }
}
