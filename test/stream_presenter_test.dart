import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/presenters.dart';

Stream<int> numberStream(int dataBack, {bool fail, int delay}) async* {
  if (fail) throw Exception('numberStream failed');
  if (delay != null) await Future.delayed(Duration(milliseconds: delay));
  yield dataBack;
}

Stream<String> textStream(String dataBack, {bool fail, int delay}) async* {
  if (fail) throw Exception('textStream failed');
  if (delay != null) await Future.delayed(Duration(milliseconds: delay));
  yield dataBack;
}

class TestStreamPresenter extends StreamPresenter<int> {
  final bool fail;
  final int delay;
  TestStreamPresenter({this.fail = false, this.delay = 0});
  int loadedData;

  @override
  get stream => numberStream(1, fail: fail, delay: delay);

  @override
  void onData(int data) {
    loadedData = data;
  }
}

const String _NumberStream = 'numberStream';
const String _StringStream = 'stringStream';

class TestStreamsPresenter extends StreamsPresenter {
  final bool failOne;
  final int delay;
  TestStreamsPresenter({this.failOne = false, this.delay = 0});
  int loadedData;
  int cancelledCalls = 0;
  @override
  Map<String, StreamData> get streamsMap => {
        _NumberStream: StreamData(numberStream(
          5,
          fail: failOne,
          delay: delay,
        )),
        _StringStream: StreamData(textStream(
          "five",
          fail: false,
          delay: delay,
        )),
      };

  @override
  void onCancel(String key) {
    cancelledCalls++;
  }
}

class TestStreamsPresenterWithOverrides extends StreamsPresenter {
  TestStreamsPresenterWithOverrides();
  int loadedData;
  @override
  Map<String, StreamData> get streamsMap => {
        _NumberStream: StreamData(
          numberStream(5, fail: false, delay: 0),
          onData: _loadData,
        )
      };

  void _loadData(data) {
    loadedData = data;
  }
}

void main() async {
  group('StreamPresenter', () {
    test('When stream data is fetched data should be set and ready', () async {
      var streamPresenter = TestStreamPresenter();
      streamPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamPresenter.data, 1);
      expect(streamPresenter.dataReady, true);
    });
    test('When stream lifecycle events are overriden they recieve correct data',
        () async {
      var streamPresenter = TestStreamPresenter();
      streamPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamPresenter.loadedData, 1);
    });

    test('When a stream fails it should indicate there\'s an error and no data',
        () async {
      var streamPresenter = TestStreamPresenter(fail: true);
      streamPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamPresenter.hasError, true);
      expect(streamPresenter.data, null,
          reason: 'No data should be set when there\'s a failure.');
      expect(streamPresenter.dataReady, false);
    });

    test('Before a stream returns it should indicate not ready', () async {
      var streamPresenter = TestStreamPresenter(delay: 1000);
      streamPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamPresenter.dataReady, false);
    });

    test('When a stream returns it should notifyListeners', () async {
      var streamPresenter = TestStreamPresenter(delay: 50);
      var listenersCalled = false;
      streamPresenter.addListener(() {
        listenersCalled = true;
      });
      streamPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 100));
      expect(listenersCalled, true);
    });

    group('Data Source Change', () {
      test(
          'notifySourceChanged - When called should unsubscribe from original source',
          () {
        var streamPresenter = TestStreamPresenter(delay: 1000);
        streamPresenter.initialize();
        streamPresenter.notifySourceChanged();
        expect(streamPresenter.streamSubscription, null);
      });

      test(
          'notifySourceChanged - When called and clearOldData is false should leave old data',
          () async {
        var streamPresenter = TestStreamPresenter(delay: 10);
        streamPresenter.initialize();
        await Future.delayed(const Duration(milliseconds: 20));
        streamPresenter.notifySourceChanged();
        expect(streamPresenter.data, 1);
      });

      test(
          'notifySourceChanged - When called and clearOldData is true should remove old data',
          () async {
        var streamPresenter = TestStreamPresenter(delay: 10);
        streamPresenter.initialize();
        await Future.delayed(const Duration(milliseconds: 20));
        streamPresenter.notifySourceChanged(clearOldData: true);
        expect(streamPresenter.data, null);
      });
    });
  });

  group('MultipleStreamViewModel', () {
    test(
        'When running multiple streams the associated key should hold the value when data is fetched',
        () async {
      var streamsPresenter = TestStreamsPresenter();
      streamsPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 4));
      expect(streamsPresenter.dataMap[_NumberStream], 5);
      expect(streamsPresenter.dataMap[_StringStream], 'five');
    });

    test(
        'When one of multiple streams fail only the failing one should have an error',
        () async {
      var streamsPresenter = TestStreamsPresenter(failOne: true);
      streamsPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamsPresenter.hasErrorForKey(_NumberStream), true);
      // Make sure we only have 1 error
      // expect(streamsPresenter.errorMap.values.where((v) => v == true).length, 1);
    });

    test(
        'When one of multiple streams fail the passed one should have data and failing one not',
        () async {
      var streamsPresenter = TestStreamsPresenter(failOne: true);
      streamsPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamsPresenter.dataReady(_NumberStream), false);
      // Delay the first lifecycle can complete
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamsPresenter.dataReady(_StringStream), true);
    });

    test('When one onData is augmented the data will change', () async {
      var streamsPresenter = TestStreamsPresenterWithOverrides();
      streamsPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamsPresenter.loadedData, 5);
    });

    test('When a stream returns it should notifyListeners', () async {
      var streamsPresenter = TestStreamsPresenter(delay: 50);
      var listenersCalled = false;
      streamsPresenter.addListener(() {
        listenersCalled = true;
      });
      streamsPresenter.initialize();
      await Future.delayed(Duration(milliseconds: 100));
      expect(listenersCalled, true);
    });

    test(
        'When a stream is initialized should have a subscription for the given key',
        () async {
      var streamsPresenter = TestStreamsPresenter();
      streamsPresenter.initialize();
      expect(
          streamsPresenter.getSubscriptionForKey(_NumberStream) != null, true);
    });

    test('When disposed, should call onCancel for both streams', () async {
      var streamsPresenter = TestStreamsPresenter();
      streamsPresenter.initialize();
      streamsPresenter.dispose();
      expect(streamsPresenter.cancelledCalls, 2);
    });
  });

  group('Data Source Change', () {
    test(
        'notifySourceChanged - When called should unsubscribe from original sources',
        () {
      var streamsPresenter = TestStreamsPresenter(delay: 50);
      streamsPresenter.initialize();
      streamsPresenter.notifySourceChanged();
      expect(streamsPresenter.streamsSubscriptions.length, 0);
    });

    test(
        'notifySourceChanged - When called and clearOldData is false should leave old data',
        () async {
      var streamsPresenter = TestStreamsPresenter(delay: 10);
      streamsPresenter.initialize();
      await Future.delayed(const Duration(milliseconds: 20));
      streamsPresenter.notifySourceChanged();
      expect(streamsPresenter.dataMap[_NumberStream], 5);
    });

    test(
        'notifySourceChanged - When called and clearOldData is true should remove old data',
        () async {
      var streamsPresenter = TestStreamsPresenter(delay: 10);
      streamsPresenter.initialize();
      await Future.delayed(const Duration(milliseconds: 20));
      streamsPresenter.notifySourceChanged(clearOldData: true);
      expect(streamsPresenter.dataMap[_NumberStream], null);
    });
  });
}
