import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  FirebaseAnalyticsObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(analytics: _analytics);

  Future logAuthentication() async {
    await _analytics.logLogin(loginMethod: 'email');
  }

  Future logEvent({String name, Object params}) async {
    await _analytics.logEvent(
      name: name,
      parameters: params,
    );
  }

  Future logRegistration() async {
    await _analytics.logSignUp(signUpMethod: 'email');
  }

  Future setUserProperties({@required String userId, String propertyName, Object propertyValue}) async {
    await _analytics.setUserId(userId);
    
    if (propertyName.isNotEmpty) {
      await _analytics.setUserProperty(
        name: propertyName, 
        value: propertyValue
      );
    }
  }
}
