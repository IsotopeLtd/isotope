import 'package:flutter/material.dart';

class Notification extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool autoDismiss;
  final Color backcolor;
  final Color color;
  final bool custom = false;
  
  const Notification(
    this.title, {this.subtitle, this.autoDismiss, this.backcolor, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color ?? Colors.grey[600],
      ),
    );
  }
}
