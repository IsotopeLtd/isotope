import 'package:isotope/reactive.dart';

/// Adds functionality to easily listen to all reactive values in a service.
mixin ReactiveServiceMixin {
  List<Function> _listeners = List<Function>();

  void listenToReactiveValues(List<dynamic> reactiveValues) {
    for (var reactiveValue in reactiveValues) {
      if (reactiveValue is ReactiveValue) {
        reactiveValue.values.listen((value) => _notifyListeners());
      } else if (reactiveValue is ReactiveList) {
        reactiveValue.onChange.listen((event) => _notifyListeners());
      }
    }
  }

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}
