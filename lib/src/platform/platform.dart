import 'platform_web.dart' if (dart.library.io) 'platform_io.dart';

class Platform {
  static bool get isWeb => PlatformInfo.isWeb;
  static bool get isMacOS => PlatformInfo.isMacOS;
  static bool get isWindows => PlatformInfo.isWindows;
  static bool get isLinux => PlatformInfo.isLinux;
  static bool get isAndroid => PlatformInfo.isAndroid;
  static bool get isIOS => PlatformInfo.isIOS;
  static bool get isFuchsia => PlatformInfo.isFuchsia;
}
