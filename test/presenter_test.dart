import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/presenters.dart';

class TestPresenter extends Presenter {
  bool onErrorCalled = false;

  Future runFuture(
      {String busyKey, bool fail = false, bool throwException = false}) {
    return runBusyFuture(
      _futureToRun(fail),
      busyObject: busyKey,
      throwException: throwException,
    );
  }

  Future runTestErrorFuture(
      {String key, bool fail = false, bool throwException = false}) {
    return runErrorFuture(
      _futureToRun(fail),
      key: key,
      throwException: throwException,
    );
  }

  Future _futureToRun(bool fail) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (fail) {
      throw Exception('Broken Future');
    }
  }

  @override
  void onFutureError(error, key) {
    onErrorCalled = true;
  }
}

void main() {
  group('Presenter Tests -', () {
    group('Busy functionality -', () {
      test('When setBusy is called with true isBusy should be true', () {
        var presenter = TestPresenter();
        presenter.setBusy(true);
        expect(presenter.isBusy, true);
      });

      test(
          'When setBusyForObject is called with parameter true busy for that object should be true',
          () {
        var property;
        var presenter = TestPresenter();
        presenter.setBusyForObject(property, true);
        expect(presenter.busy(property), true);
      });

      test(
          'When setBusyForObject is called with true then false, should be false',
          () {
        var property;
        var presenter = TestPresenter();
        presenter.setBusyForObject(property, true);
        presenter.setBusyForObject(property, false);
        expect(presenter.busy(property), false);
      });

      test('When busyFuture is run should report busy for the model', () {
        var presenter = TestPresenter();
        presenter.runFuture();
        expect(presenter.isBusy, true);
      });

      test(
          'When busyFuture is run with busyObject should report busy for the Object',
          () {
        var busyObjectKey = 'busyObjectKey';
        var presenter = TestPresenter();
        presenter.runFuture(busyKey: busyObjectKey);
        expect(presenter.busy(busyObjectKey), true);
      });

      test(
          'When busyFuture is run with busyObject should report NOT busy when error is thrown',
          () async {
        var busyObjectKey = 'busyObjectKey';
        var presenter = TestPresenter();
        await presenter.runFuture(busyKey: busyObjectKey, fail: true);
        expect(presenter.busy(busyObjectKey), false);
      });

      test(
          'When busyFuture is run with busyObject should throw exception if throwException is set to true',
          () async {
        var busyObjectKey = 'busyObjectKey';
        var presenter = TestPresenter();
        expect(
            () async => await presenter.runFuture(
                busyKey: busyObjectKey, fail: true, throwException: true),
            throwsException);
      });

      test(
          'When busy future is complete should have called notifyListeners twice, 1 for busy 1 for not busy',
          () async {
        var called = 0;
        var presenter = TestPresenter();
        presenter.addListener(() {
          ++called;
        });
        await presenter.runFuture();
        expect(called, 2);
      });

      test(
          'When busy future fails should have called notifyListeners three times, 1 for busy 1 for not busy and 1 for error',
          () async {
        var called = 0;
        var presenter = TestPresenter();
        presenter.addListener(() {
          ++called;
        });
        await presenter.runFuture(fail: true);
        expect(called, 3);
      });

      test(
          'When notifyListeners is called before dispose, should not throw exception',
          () async {
        var presenter = TestPresenter();
        await presenter.runFuture();
        presenter.notifyListeners();
        presenter.dispose();
        expect(() => presenter.notifyListeners(), returnsNormally);
      });

      test(
          'When notifyListeners is called after dispose, should not throw exception',
          () async {
        var presenter = TestPresenter();
        await presenter.runFuture();
        presenter.dispose();
        presenter.notifyListeners();
        expect(() => presenter.notifyListeners(), returnsNormally);
      });
    });

    group('runErrorFuture -', () {
      test('When called and error is thrown should set error', () async {
        var presenter = TestPresenter();
        await presenter.runTestErrorFuture(fail: true);
        expect(presenter.hasError, true);
      });

      test(
          'When called and error is thrown should call onErrorForFuture override',
          () async {
        var presenter = TestPresenter();
        await presenter.runTestErrorFuture(fail: true, throwException: false);
        expect(presenter.onErrorCalled, true);
      });
    });
  });
}
