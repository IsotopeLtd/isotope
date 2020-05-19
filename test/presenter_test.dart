import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/presenters.dart';

class TestPresenter extends Presenter {
  Future runFuture([String busyKey]) {
    return runBusyFuture(
      Future.delayed(Duration(milliseconds: 50)),
      busyObject: busyKey,
    );
  }
}

void main() {
  group('Presenter Tests', () {
    group('Busy functionality', () {
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
        presenter.runFuture(busyObjectKey);
        expect(presenter.busy(busyObjectKey), true);
      });
    });
  });
}
