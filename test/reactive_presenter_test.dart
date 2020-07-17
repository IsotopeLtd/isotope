import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/reactive.dart';
import 'package:isotope/presenters.dart';

class TestReactiveService with ReactiveServiceMixin {
  ReactiveValue<int> _counter = ReactiveValue(initial: 0);
  int get counter => _counter.value;

  TestReactiveService() {
    listenToReactiveValues([_counter]);
  }

  void updateCounter() {
    _counter.value++;
  }
}

class TestReactivePresenter extends ReactivePresenter {
  final _testService = TestReactiveService();

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_testService];

  void updateCounter() {
    _testService.updateCounter();
  }
}

class TestFutureReactivePresenter extends FuturePresenter<int> {
  final _testService = TestReactiveService();
  @override
  List<ReactiveServiceMixin> get reactiveServices => [_testService];

  @override
  Future<int> futureToRun() async {
    await Future.delayed(Duration(milliseconds: 5));
    return 1;
  }

  void updateCounter() {
    _testService.updateCounter();
  }
}

void main() {
  group('ReactivePresenter Tests -', () {
    test(
        'Given a reactive service should notifyListeners when a reactive value in it changes',
        () async {
      var presenter = TestReactivePresenter();
      var called = false;

      presenter.addListener(() {
        called = true;
      });

      presenter.updateCounter();
      await Future.delayed(Duration(milliseconds: 5));
      expect(called, true);
    });

    test(
        'Given a reactive service on FuturePresenter should notifyListeners when a reactive value in it changes',
        () async {
      var presenter = TestFutureReactivePresenter();
      var called = false;

      presenter.addListener(() {
        called = true;
      });

      presenter.updateCounter();
      await Future.delayed(Duration(milliseconds: 5));
      expect(called, true);
    });

    test('Given a reactive service should not notifyListeners after disposed',
        () async {
      var presenter = TestReactivePresenter();
      var called = false;

      presenter.addListener(() {
        called = true;
      });

      presenter.dispose();
      presenter.updateCounter();
      await Future.delayed(Duration(milliseconds: 5));
      expect(called, false);
    });
  });
}
