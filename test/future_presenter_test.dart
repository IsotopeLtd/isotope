import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/presenters.dart';

const _FutureExceptionFailMessage = 'Future to Run failed';

class TestFuturePresenter extends FuturePresenter<int> {
  final bool fail;
  TestFuturePresenter({this.fail = false});

  int numberToReturn = 5;
  bool dataCalled = false;

  @override
  Future<int> futureToRun() async {
    if (fail) throw Exception(_FutureExceptionFailMessage);
    await Future.delayed(Duration(milliseconds: 20));
    return numberToReturn;
  }

  @override
  void onData(int data) {
    dataCalled = true;
  }
}

const String NumberDelayFuture = 'delayedNumber';
const String StringDelayFuture = 'delayedString';
const String _NumberDelayExceptionMessage = 'getNumberAfterDelay failed';

class TestFuturesPresenter extends FuturesPresenter {
  final bool failOne;
  final int futureOneDuration;
  final int futureTwoDuration;
  TestFuturesPresenter(
      {this.failOne = false,
      this.futureOneDuration = 300,
      this.futureTwoDuration = 400});

  int numberToReturn = 5;

  @override
  Map<String, Future Function()> get futuresMap => {
        NumberDelayFuture: getNumberAfterDelay,
        StringDelayFuture: getStringAfterDelay,
      };

  Future<int> getNumberAfterDelay() async {
    if (failOne) {
      throw Exception(_NumberDelayExceptionMessage);
    }
    await Future.delayed(Duration(milliseconds: futureOneDuration));
    return numberToReturn;
  }

  Future<String> getStringAfterDelay() async {
    await Future.delayed(Duration(milliseconds: futureTwoDuration));
    return 'String data';
  }
}

void main() {
  group('FuturePresenter', () {
    test('When future is complete data should be set and ready', () async {
      var futurePresenter = TestFuturePresenter();
      await futurePresenter.initialize();
      expect(futurePresenter.data, 5);
      expect(futurePresenter.dataReady, true);
    });

    test('When a future fails it should indicate there\'s an error and no data',
        () async {
      var futurePresenter = TestFuturePresenter(fail: true);
      await futurePresenter.initialize();
      expect(futurePresenter.hasError, true);
      expect(futurePresenter.data, null,
          reason: 'No data should be set when there\'s a failure.');
      expect(futurePresenter.dataReady, false);
    });

    test('When a future runs it should indicate busy', () async {
      var futurePresenter = TestFuturePresenter();
      futurePresenter.initialize();
      expect(futurePresenter.isBusy, true);
    });

    test('When a future fails it should indicate NOT busy', () async {
      var futurePresenter = TestFuturePresenter(fail: true);
      await futurePresenter.initialize();
      expect(futurePresenter.isBusy, false);
    });

    test('When a future fails it should set error to exception', () async {
      var futurePresenter = TestFuturePresenter(fail: true);
      await futurePresenter.initialize();
      expect(futurePresenter.modelError.message, _FutureExceptionFailMessage);
    });

    test('When a future fails onData should not be called', () async {
      var futurePresenter = TestFuturePresenter(fail: true);
      await futurePresenter.initialize();
      expect(futurePresenter.dataCalled, false);
    });

    test('When a future passes onData should not called', () async {
      var futurePresenter = TestFuturePresenter();
      await futurePresenter.initialize();
      expect(futurePresenter.dataCalled, true);
    });

    group('Dynamic Source Tests', () {
      test('notifySourceChanged - When called should re-run Future', () async {
        var futurePresenter = TestFuturePresenter();
        await futurePresenter.initialize();
        expect(futurePresenter.data, 5);
        futurePresenter.numberToReturn = 10;
        futurePresenter.notifySourceChanged();
        await futurePresenter.initialize();
        expect(futurePresenter.data, 10);
      });
    });
  });

  group('FuturesPresenter -', () {
    test(
        'When running multiple futures the associated key should hold the value when complete',
        () async {
      var futuresPresenter = TestFuturesPresenter();
      await futuresPresenter.initialize();

      expect(futuresPresenter.dataMap[NumberDelayFuture], 5);
      expect(futuresPresenter.dataMap[StringDelayFuture], 'String data');
    });

    test(
        'When one of multiple futures fail only the failing one should have an error',
        () async {
      var futuresPresenter = TestFuturesPresenter(failOne: true);
      await futuresPresenter.initialize();

      expect(futuresPresenter.hasErrorForKey(NumberDelayFuture), true);
      expect(futuresPresenter.hasErrorForKey(StringDelayFuture), false);
    });

    test(
        'When one of multiple futures fail the passed one should have data and failing one not',
        () async {
      var futuresPresenter = TestFuturesPresenter(failOne: true);
      await futuresPresenter.initialize();

      expect(futuresPresenter.dataMap[NumberDelayFuture], null);
      expect(futuresPresenter.dataMap[StringDelayFuture], 'String data');
    });

    test('When multiple futures run the key should be set to indicate busy',
        () async {
      var futuresPresenter = TestFuturesPresenter();
      futuresPresenter.initialize();

      expect(futuresPresenter.busy(NumberDelayFuture), true);
      expect(futuresPresenter.busy(StringDelayFuture), true);
    });

    test(
        'When multiple futures are complete the key should be set to indicate NOT busy',
        () async {
      var futuresPresenter = TestFuturesPresenter();
      await futuresPresenter.initialize();

      expect(futuresPresenter.busy(NumberDelayFuture), false);
      expect(futuresPresenter.busy(StringDelayFuture), false);
    });

    test('When a future fails busy should be set to false', () async {
      var futuresPresenter = TestFuturesPresenter(failOne: true);
      await futuresPresenter.initialize();

      expect(futuresPresenter.busy(NumberDelayFuture), false);
      expect(futuresPresenter.busy(StringDelayFuture), false);
    });

    test('When a future fails should set error for future key', () async {
      var futuresPresenter = TestFuturesPresenter(failOne: true);
      await futuresPresenter.initialize();

      expect(futuresPresenter.error(NumberDelayFuture).message,
          _NumberDelayExceptionMessage);

      expect(futuresPresenter.error(StringDelayFuture), null);
    });

    test(
        'When one future is still running out of two anyObjectsBusy should return true',
        () async {
      var futuresPresenter =
          TestFuturesPresenter(futureOneDuration: 10, futureTwoDuration: 60);
      futuresPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 30));

      expect(futuresPresenter.busy(NumberDelayFuture), false,
          reason: 'String future should be done at this point');
      expect(futuresPresenter.anyObjectsBusy, true,
          reason: 'Should be true because second future is still running');
    });

    group('Dynamic Source Tests', () {
      test('notifySourceChanged - When called should re-run Future', () async {
        var futuresPresenter = TestFuturesPresenter();
        await futuresPresenter.initialize();
        expect(futuresPresenter.dataMap[NumberDelayFuture], 5);
        futuresPresenter.numberToReturn = 10;
        futuresPresenter.notifySourceChanged();
        await futuresPresenter.initialize();
        expect(futuresPresenter.dataMap[NumberDelayFuture], 10);
      });
    });
  });
}
