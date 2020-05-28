import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:isotope/src/platform/platform.dart';
import 'package:isotope/src/registrar/registrar.dart';
import 'package:isotope/src/services/navigation_service.dart';

class PushNotificationService {
  final Registrar serviceManager;
  final String route;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  NavigationService _navigationService;

  PushNotificationService({this.serviceManager, this.route});

  Future initialise() async {
    _navigationService = serviceManager<NavigationService>();

    if (Platform.isIOS) {
      // request permissions if we're on iOS
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      // Called when the app is in the foreground and we receive a push notification
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      // Called when the app has been closed comlpetely and it's opened
      // from the push notification.
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _serialiseAndNavigate(message);
      },
      // Called when the app is in the background and it's opened
      // from the push notification.
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        _serialiseAndNavigate(message);
      },
    );
  }

  void _serialiseAndNavigate(Map<String, dynamic> message) {
    var notificationData = message['data'];
    var view = notificationData['view'];

    if (view != null) {
      // Navigate to the create project view
      if (view == 'create_post') {
        _navigationService.navigateTo(route);
      }
    }
  }
}
