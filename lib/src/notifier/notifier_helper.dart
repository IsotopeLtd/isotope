import 'package:flutter/material.dart';
import 'package:isotope/src/notifier/notifier.dart';

class NotifierHelper {
  /// Get a success notification notifier.
  static Notifier createSuccess(
      {@required String message,
      String title,
      Duration duration = const Duration(seconds: 3)}) {
    return Notifier(
      title: title,
      message: message,
      icon: Icon(
        Icons.check_circle,
        color: Colors.green[300],
      ),
      leftBarIndicatorColor: Colors.green[300],
      duration: duration,
    );
  }

  /// Get an information notification notifier
  static Notifier createInformation(
      {@required String message,
      String title,
      Duration duration = const Duration(seconds: 3)}) {
    return Notifier(
      title: title,
      message: message,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      ),
      leftBarIndicatorColor: Colors.blue[300],
      duration: duration,
    );
  }

  /// Get a error notification notifier
  static Notifier createError(
      {@required String message,
      String title,
      Duration duration = const Duration(seconds: 3)}) {
    return Notifier(
      title: title,
      message: message,
      icon: Icon(
        Icons.warning,
        size: 28.0,
        color: Colors.red[300],
      ),
      leftBarIndicatorColor: Colors.red[300],
      duration: duration,
    );
  }

  /// Get a notifier that can receive a user action through a button.
  static Notifier createAction(
      {@required String message,
      @required FlatButton button,
      String title,
      Duration duration = const Duration(seconds: 3)}) {
    return Notifier(
      title: title,
      message: message,
      duration: duration,
      mainButton: button,
    );
  }

  // Get a notifier that shows the progress of a async computation.
  static Notifier createLoading(
      {@required String message,
      @required LinearProgressIndicator linearProgressIndicator,
      String title,
      Duration duration = const Duration(seconds: 3),
      AnimationController progressIndicatorController,
      Color progressIndicatorBackgroundColor}) {
    return Notifier(
      title: title,
      message: message,
      icon: Icon(
        Icons.cloud_upload,
        color: Colors.blue[300],
      ),
      duration: duration,
      showProgressIndicator: true,
      progressIndicatorController: progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
    );
  }

  /// Get a notifier that shows an user input form.
  static Notifier createInputFlushbar({@required Form textForm}) {
    return Notifier(
      duration: null,
      userInputForm: textForm,
    );
  }
}
