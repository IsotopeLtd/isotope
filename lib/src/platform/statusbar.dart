import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future darkChrome() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white, // Color for Android
      statusBarBrightness: Brightness.dark // Dark == white status bar -- for IOS.
    )
  );
}

Future lightChrome() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.black, // Color for Android
      statusBarBrightness: Brightness.light // Light == black status bar -- for IOS.
    )
  );
}
