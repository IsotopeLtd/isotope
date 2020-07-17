import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/reactive.dart';
import 'package:isotope/presenters.dart';

class CounterService with ReactiveServiceMixin {
  ReactiveValue<int> _counter = ReactiveValue<int>(initial: 0);
  int get counter => _counter.value;

  ReactiveList<int> _counters = ReactiveList<int>();
  ReactiveList get counters => _counters;

  CounterService() {
    listenToReactiveValues([
      _counter,
    ]);
  }

  void updateCounter() {
    _counter.value++;
  }

  void addCounterToList() {
    _counters.add(_counter.value);
  }
}

class MultipleCounterService with ReactiveServiceMixin {
  ReactiveList<int> _counters = ReactiveList<int>();
  ReactiveList get counters => _counters;
  int _counter = 0;

  MultipleCounterService() {
    listenToReactiveValues([
      _counters,
    ]);
  }

  void addCounterToList() {
    _counters.add(_counter++);
  }
}

void main() {
  group('Reactive Functionality', () {
    test(
        'When ReactiveValue updates on reactive service, should call listeners',
        () async {
      var called = false;
      var reactiveService = CounterService();

      reactiveService.addListener(() {
        called = true;
      });

      reactiveService.updateCounter();

      // Have to wait for the listener to be called above. In real life the results is not
      // expected to happen in the same CPU cycle so this is perfect for a unit test.
      await Future.delayed(Duration(milliseconds: 10));

      expect(called, true);
    });

    test('When ReactiveList updates on reactive service, should call listeners',
        () async {
      var called = false;
      var reactiveService = MultipleCounterService();

      reactiveService.addListener(() {
        called = true;
      });

      reactiveService.addCounterToList();

      // Have to wait for the listener to be called above. In real life the results is not
      // expected to happen in the same CPU cycle so this is perfect for a unit test.
      await Future.delayed(Duration(milliseconds: 10));

      expect(called, true);
    });
  });
}
