import 'package:flutter/widgets.dart';

/// Wrap your root App widget in this widget and
///  call [Isotope.restart] to restart your app.
class Isotope extends StatefulWidget {
  final Widget child;

  Isotope({this.child});

  @override
  _IsotopeState createState() => _IsotopeState();

  static restart(BuildContext context) {
    context.findAncestorStateOfType<_IsotopeState>().restart();
  }
}

class _IsotopeState extends State<Isotope> {
  Key _key = UniqueKey();

  void restart() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}
