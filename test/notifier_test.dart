import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/notifier.dart';

void main() {
  test('Test Notifier basic initialization', () async {
    final notifier = new Notifier(message: "This is a test");
    expect(notifier.title, null);
    expect(notifier.message, "This is a test");
    expect(notifier.duration, null);
    expect(notifier.backgroundColor, Color(0xFF303030));
    expect(notifier.notifierPosition, NotifierPosition.bottom);
    expect(notifier.notifierStyle, NotifierStyle.floating);
    expect(notifier.forwardAnimationCurve, Curves.easeOutCirc);
    expect(notifier.reverseAnimationCurve, Curves.easeOutCirc);
    expect(notifier.titleText, null);
    expect(notifier.messageText, null);
    expect(notifier.icon, null);
    expect(notifier.leftBarIndicatorColor, null);
    expect(notifier.boxShadows, null);
    expect(notifier.backgroundGradient, null);
    expect(notifier.mainButton, null);
    expect(notifier.borderRadius, 0.0);
    expect(notifier.borderWidth, 1.0);
    expect(notifier.borderColor, null);
    expect(notifier.padding.left, 16);
    expect(notifier.padding.right, 16);
    expect(notifier.padding.top, 16);
    expect(notifier.padding.bottom, 16);
    expect(notifier.margin.left, 0);
    expect(notifier.margin.right, 0);
    expect(notifier.margin.top, 0);
    expect(notifier.margin.bottom, 0);
    expect(notifier.onTap, null);
    expect(notifier.isDismissible, true);
    expect(notifier.dismissDirection, NotifierDismissDirection.vertical);
    expect(notifier.showProgressIndicator, false);
    expect(notifier.progressIndicatorController, null);
    expect(notifier.progressIndicatorBackgroundColor, null);
    expect(notifier.progressIndicatorValueColor, null);
    expect(notifier.routeBlur, null);
    expect(notifier.routeColor, null);
    expect(notifier.isShowing(), false);
    expect(notifier.isDismissed(), false);
    expect(await notifier.dismiss(), null);
  });
}
