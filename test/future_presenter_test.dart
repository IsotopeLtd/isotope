import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/presenters.dart';

const _SingleFutureExceptionFailMessage = 'futureToRun() failed';

class TestFuturePresenter extends FuturePresenter<int> {
  final bool fail;
  TestFuturePresenter({this.fail = false});

  int numberToReturn = 5;

  @override
  Future<int> futureToRun() async {
    if (fail) throw Exception(_SingleFutureExceptionFailMessage);
    await Future.delayed(Duration(milliseconds: 20));
    return numberToReturn;
  }
}

const String NumberDelayFuture = 'delayedNumber';
const String StringDelayFuture = 'delayedString';
const String _NumberDelayExceptionMessage = 'getNumberAfterDelay() failed';

class TestFuturesPresenter extends FuturesPresenter {
  final bool failOne;
  TestFuturesPresenter({this.failOne = false});

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
    await Future.delayed(Duration(milliseconds: 300));
    return numberToReturn;
  }

  Future<String> getStringAfterDelay() async {
    await Future.delayed(Duration(milliseconds: 400));
    return 'String data';
  }
}

void main() {
  group('FuturePresenter', () {
    test('When future is complete data should be set and ready', () async {
      var futurePresenter = TestFuturePresenter();
      await futurePresenter.runFuture();
      expect(futurePresenter.data, 5);
      expect(futurePresenter.dataReady, true);
    });

    test('When a future fails it should indicate there\'s an error and no data',
        () async {
      var futurePresenter = TestFuturePresenter(fail: true);
      await futurePresenter.runFuture();
      expect(futurePresenter.hasError, true);
      expect(futurePresenter.data, null, reason: 'No data should be set when there\'s a failure.');
      expect(futurePresenter.dataReady, false);
    });

    test('When a future runs it should indicate busy', () async {
      var futurePresenter = TestFuturePresenter();
      futurePresenter.runFuture();
      expect(futurePresenter.isBusy, true);
    });

    test('When a future fails it should indicate NOT busy', () async {
      var futurePresenter = TestFuturePresenter(fail: true);
      await futurePresenter.runFuture();
      expect(futurePresenter.isBusy, false);
    });

    test('When a future fails it should set error to exception', () async {
      var futurePresenter = TestFuturePresenter(fail: true);
      await futurePresenter.runFuture();
      expect(futurePresenter.error.message, _SingleFutureExceptionFailMessage);
    });

    group('Dynamic Source Tests', () {
      test('notifySourceChanged - When called should re-run future', () async {
        var futurePresenter = TestFuturePresenter();
        await futurePresenter.runFuture();
        expect(futurePresenter.data, 5);
        futurePresenter.numberToReturn = 10;
        futurePresenter.notifySourceChanged();
        await futurePresenter.runFuture();
        expect(futurePresenter.data, 10);
      });
    });
  });

  group('FuturesPresenter', () {
    test(
        'When running multiple futures the associated key should hold the value when complete',
        () async {
      var futuresPresenter = TestFuturesPresenter();
      await futuresPresenter.runFutures();

      expect(futuresPresenter.dataMap[NumberDelayFuture], 5);
      expect(futuresPresenter.dataMap[StringDelayFuture], 'String data');
    });

    test(
        'When one of multiple futures fail only the failing one should have an error',
        () async {
      var futuresPresenter = TestFuturesPresenter(failOne: true);
      await futuresPresenter.runFutures();

      expect(futuresPresenter.hasError(NumberDelayFuture), true);
      expect(futuresPresenter.hasError(StringDelayFuture), false);
    });

    test(
        'When one of multiple futures fail the passed one should have data and failing one not',
        () async {
      var futuresPresenter = TestFuturesPresenter(failOne: true);
      await futuresPresenter.runFutures();

      expect(futuresPresenter.dataMap[NumberDelayFuture], null);
      expect(futuresPresenter.dataMap[StringDelayFuture], 'String data');
    });

    test('When multiple futures run the key should be set to indicate busy',
        () async {
      var futuresPresenter = TestFuturesPresenter();
      futuresPresenter.runFutures();

      expect(futuresPresenter.busy(NumberDelayFuture), true);
      expect(futuresPresenter.busy(StringDelayFuture), true);
    });

    test(
        'When multiple futures are complete the key should be set to indicate NOT busy',
        () async {
      var futuresPresenter = TestFuturesPresenter();
      await futuresPresenter.runFutures();

      expect(futuresPresenter.busy(NumberDelayFuture), false);
      expect(futuresPresenter.busy(StringDelayFuture), false);
    });

    test('When a future fails busy should be set to false', () async {
      var futuresPresenter = TestFuturesPresenter(failOne: true);
      await futuresPresenter.runFutures();

      expect(futuresPresenter.busy(NumberDelayFuture), false);
      expect(futuresPresenter.busy(StringDelayFuture), false);
    });

    test('When a future fails should set error for future key', () async {
      var futuresPresenter = TestFuturesPresenter(failOne: true);
      await futuresPresenter.runFutures();

      expect(futuresPresenter.getError(NumberDelayFuture).message, _NumberDelayExceptionMessage);
      expect(futuresPresenter.getError(StringDelayFuture), null);
    });

    group('Dynamic Source Tests', () {
      test('notifySourceChanged - When called should re-run future', () async {
        var futuresPresenter = TestFuturesPresenter();
        await futuresPresenter.runFutures();
        expect(futuresPresenter.dataMap[NumberDelayFuture], 5);
        futuresPresenter.numberToReturn = 10;
        futuresPresenter.notifySourceChanged();
        await futuresPresenter.runFutures();
        expect(futuresPresenter.dataMap[NumberDelayFuture], 10);
      });
    });
  });
}
