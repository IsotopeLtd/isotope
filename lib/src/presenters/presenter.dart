import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:isotope/src/presenters/reactive_service_mixin.dart';

/// Contains Presenter functionality for busy state management.
class Presenter extends ChangeNotifier {
  Map<int, bool> _busyStates = Map<int, bool>();
  Map<int, dynamic> _errorStates = Map<int, dynamic>();

  bool _initialized = false;
  bool get initialized => _initialized;

  bool _onPresenterReadyCalled = false;
  bool get onPresenterReadyCalled => _onPresenterReadyCalled;

  bool _disposed = false;
  bool get disposed => _disposed;

  /// Returns the busy status for an object if it exists. Returns false if not present.
  bool busy(Object object) => _busyStates[object.hashCode] ?? false;

  dynamic error(Object object) => _errorStates[object.hashCode];

  /// Returns the busy status of the presenter.
  bool get isBusy => busy(this);

  /// Returns the error status of the presenter.
  bool get hasError => error(this) != null;

  /// Returns the error status of the presenter.
  dynamic get modelError => error(this);

  // Returns true if any objects still have a busy status that is true.
  bool get anyObjectsBusy => _busyStates.values.any((busy) => busy);

  /// Marks the presenter as busy and calls notify listeners.
  void setBusy(bool value) {
    setBusyForObject(this, value);
  }

  /// Sets the error for the presenter.
  void setError(dynamic error) {
    setErrorForObject(this, error);
  }

  /// Returns a boolean that indicates if the presenter has an error for the key.
  bool hasErrorForKey(Object key) => error(key) != null;

  /// Clears all the errors
  void clearErrors() {
    _errorStates.clear();
  }

  /// Sets the busy state for the object equal to the value passed in and notifies listeners.
  /// If you're using a primitive type the value SHOULD NOT BE CHANGED, since Hashcode uses == value.
  void setBusyForObject(Object object, bool value) {
    _busyStates[object.hashCode] = value;
    notifyListeners();
  }

  /// Sets the error state for the object equal to the value passed in and notifies listeners.
  /// If you're using a primitive type the value SHOULD NOT BE CHANGED, since Hashcode uses == value.
  void setErrorForObject(Object object, dynamic value) {
    _errorStates[object.hashCode] = value;
    notifyListeners();
  }

  /// Function that is called when a future throws an error.
  void onFutureError(dynamic error, Object key) {}

  /// Sets the presenter to busy, runs the future and then sets it to not busy when complete.
  /// rethrows [Exception] after setting busy to false for object or class.
  Future runBusyFuture(Future busyFuture,
      {Object busyObject, bool throwException = false}) async {
    _setBusyForPresenterOrObject(true, busyObject: busyObject);
    try {
      var value = await runErrorFuture(busyFuture,
          key: busyObject, throwException: throwException);
      _setBusyForPresenterOrObject(false, busyObject: busyObject);
      return value;
    } catch (e) {
      _setBusyForPresenterOrObject(false, busyObject: busyObject);
      if (throwException) rethrow;
    }
  }

  Future runErrorFuture(Future future,
      {Object key, bool throwException = false}) async {
    try {
      return await future;
    } catch (e) {
      _setErrorForPresenterOrObject(e, key: key);
      onFutureError(e, key);
      if (throwException) rethrow;
      return Future.value();
    }
  }

  /// Sets the initialized value for the presenter to true. This is called after
  /// the first initialize special presenter call.
  void setInitialized(bool value) {
    _initialized = value;
  }

  /// Sets the onPresenterReadyCalled value to true.
  /// This is called after this first onPresenterReady call.
  void setOnPresenterReadyCalled(bool value) {
    _onPresenterReadyCalled = value;
  }

  void _setBusyForPresenterOrObject(bool value, {Object busyObject}) {
    if (busyObject != null) {
      setBusyForObject(busyObject, value);
    } else {
      setBusyForObject(this, value);
    }
  }

  void _setErrorForPresenterOrObject(dynamic value, {Object key}) {
    if (key != null) {
      setErrorForObject(key, value);
    } else {
      setErrorForObject(this, value);
    }
  }

  // Sets up streamData property to hold data, busy, and lifecycle events.
  @protected
  StreamData setupStream<T>(
    Stream<T> stream, {
    onData,
    onSubscribed,
    onError,
    onCancel,
    transformData,
  }) {
    StreamData<T> streamData = StreamData<T>(
      stream,
      onData: onData,
      onSubscribed: onSubscribed,
      onError: onError,
      onCancel: onCancel,
      transformData: transformData,
    );
    streamData.initialize();

    return streamData;
  }

  @override
  void notifyListeners() {
    if (!disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// A [Presenter] that provides functionality to subscribe to
/// a reactive service.
abstract class ReactivePresenter extends Presenter {
  List<ReactiveServiceMixin> _reactiveServices;
  List<ReactiveServiceMixin> get reactiveServices;

  ReactivePresenter() {
    _reactToServices(reactiveServices);
  }

  void _reactToServices(List<ReactiveServiceMixin> reactiveServices) {
    _reactiveServices = reactiveServices;
    for (var reactiveService in _reactiveServices) {
      reactiveService.addListener(_indicateChange);
    }
  }

  @override
  void dispose() {
    for (var reactiveService in _reactiveServices) {
      reactiveService.removeListener(_indicateChange);
    }
    super.dispose();
  }

  void _indicateChange() {
    notifyListeners();
  }
}

@protected
class DynamicSourcePresenter<T> extends ReactivePresenter {
  bool changeSource = false;
  void notifySourceChanged({bool clearOldData = false}) {
    changeSource = true;
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}

class _SourcePresenter<T> extends DynamicSourcePresenter {
  T _data;
  T get data => _data;

  dynamic _error;

  @override
  dynamic error([Object object]) => _error;

  bool get dataReady => _data != null && !hasError;
}

class _SourcesPresenter extends DynamicSourcePresenter {
  Map<String, dynamic> _dataMap;
  Map<String, dynamic> get dataMap => _dataMap;

  bool dataReady(String key) => _dataMap[key] != null && (error(key) == null);
}

/// Provides functionality for a presenter whose sole purpose is to fetch data using a future.
abstract class FuturePresenter<T> extends _SourcePresenter<T>
    implements Initializable {
  /// The future that fetches the data and sets the presenter to busy.
  Future<T> futureToRun();

  Future initialize() async {
    setError(null);
    _error = null;

    // We set busy manually as well because when notify listeners is called to clear error messages the
    // ui is rebuilt and if you expect busy to be true it's not.
    setBusy(true);
    notifyListeners();

    _data = await runBusyFuture(futureToRun(), throwException: true)
        .catchError((error) {
      setError(error);
      _error = error;
      setBusy(false);
      onError(error);
      notifyListeners();
    });

    if (_data != null) {
      onData(_data);
    }

    changeSource = false;
  }

  /// Called when an error occurs within the future being run.
  void onError(error) {}

  /// Called after the data has been set.
  void onData(T data) {}
}

/// Provides functionality for a presenter to run and fetch data
/// using multiple futures.
abstract class FuturesPresenter extends _SourcesPresenter
    implements Initializable {
  Map<String, Future Function()> get futuresMap;

  Completer _futuresCompleter;
  int _futuresCompleted;

  void _initializeData() {
    if (_dataMap == null) {
      _dataMap = Map<String, dynamic>();
    }

    _futuresCompleted = 0;
  }

  Future initialize() {
    _futuresCompleter = Completer();
    _initializeData();

    // We set busy manually as well because when notify listeners is called to clear error messages the
    // ui is rebuilt and if you expect busy to be true it's not.
    setBusy(true);
    notifyListeners();

    for (var key in futuresMap.keys) {
      runBusyFuture(futuresMap[key](), busyObject: key, throwException: true)
          .then((futureData) {
        _dataMap[key] = futureData;
        setBusyForObject(key, false);
        notifyListeners();
        onData(key);
        _incrementAndCheckFuturesCompleted();
      }).catchError((error) {
        setErrorForObject(key, error);
        setBusyForObject(key, false);
        onError(key: key, error: error);
        notifyListeners();
        _incrementAndCheckFuturesCompleted();
      });
    }

    changeSource = false;

    return _futuresCompleter.future;
  }

  void _incrementAndCheckFuturesCompleted() {
    _futuresCompleted++;
    if (_futuresCompleted == futuresMap.length &&
        !_futuresCompleter.isCompleted) {
      _futuresCompleter.complete();
    }
  }

  void onError({String key, error}) {}

  void onData(String key) {}
}

class IndexedPresenter extends Presenter {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _reverse = false;

  /// Indicates whether we're going forward or backward in terms of the index we're changing.
  /// This is very helpful for the page transition directions.
  bool get reverse => _reverse;

  void setIndex(int value) {
    if (value < _currentIndex) {
      _reverse = true;
    } else {
      _reverse = false;
    }
    _currentIndex = value;
    notifyListeners();
  }

  bool isIndexSelected(int index) => _currentIndex == index;
}

/// Provides functionality for a presenter to run and fetch
/// data using multiple streams.
abstract class StreamsPresenter extends _SourcesPresenter
    implements Initializable {
  // Every StreamsPresenter must override streamDataMap.
  // StreamData requires a stream, but lifecycle events are optional.
  // If a lifecyle event isn't defined we use the default ones here.
  Map<String, StreamData> get streamsMap;
  Map<String, StreamSubscription> _streamsSubscriptions;

  @visibleForTesting
  Map<String, StreamSubscription> get streamsSubscriptions =>
      _streamsSubscriptions;

  /// Returns the stream subscription associated with the key.
  StreamSubscription getSubscriptionForKey(String key) =>
      _streamsSubscriptions[key];

  void initialize() {
    _dataMap = Map<String, dynamic>();
    clearErrors();
    _streamsSubscriptions = Map<String, StreamSubscription>();

    if (!changeSource) {
      notifyListeners();
    }

    for (var key in streamsMap.keys) {
      // If a lifecycle function isn't supplied, we fallback to default.
      _streamsSubscriptions[key] = streamsMap[key].stream.listen(
        (incomingData) {
          setErrorForObject(key, null);
          notifyListeners();
          // Extra security in case transformData isnt sent.
          var interceptedData = streamsMap[key].transformData == null
              ? transformData(key, incomingData)
              : streamsMap[key].transformData(incomingData);

          if (interceptedData != null) {
            _dataMap[key] = interceptedData;
          } else {
            _dataMap[key] = incomingData;
          }

          notifyListeners();
          streamsMap[key].onData != null
              ? streamsMap[key].onData(_dataMap[key])
              : onData(key, _dataMap[key]);
        },
        onError: (error) {
          setErrorForObject(key, error);
          _dataMap[key] = null;

          streamsMap[key].onError != null
              ? streamsMap[key].onError(error)
              : onError(key, error);
          notifyListeners();
        },
      );

      streamsMap[key].onSubscribed != null
          ? streamsMap[key].onSubscribed()
          : onSubscribed(key);
      changeSource = false;
    }
  }

  @override
  void notifySourceChanged({bool clearOldData = false}) {
    changeSource = true;
    _disposeAllSubscriptions();

    if (clearOldData) {
      dataMap.clear();
      clearErrors();
    }

    notifyListeners();
  }

  void onData(String key, dynamic data) {}
  void onSubscribed(String key) {}
  void onError(String key, error) {}
  void onCancel(String key) {}

  dynamic transformData(String key, data) {
    return data;
  }

  @override
  @mustCallSuper
  void dispose() {
    _disposeAllSubscriptions();
    super.dispose();
  }

  void _disposeAllSubscriptions() {
    if (_streamsSubscriptions != null) {
      for (var key in _streamsSubscriptions.keys) {
        _streamsSubscriptions[key].cancel();
        onCancel(key);
      }

      _streamsSubscriptions.clear();
    }
  }
}

abstract class StreamPresenter<T> extends _SourcePresenter<T>
    implements DynamicSourcePresenter, Initializable {
  Stream<T> get stream;
  StreamSubscription get streamSubscription => _streamSubscription;
  StreamSubscription _streamSubscription;

  @override
  void notifySourceChanged({bool clearOldData = false}) {
    changeSource = true;
    _streamSubscription?.cancel();
    _streamSubscription = null;

    if (clearOldData) {
      _data = null;
    }

    notifyListeners();
  }

  void initialize() {
    _streamSubscription = stream.listen(
      (incomingData) {
        setError(null);
        _error = null;
        notifyListeners();
        // Extra security in case transformData is not sent.
        var interceptedData =
            transformData == null ? incomingData : transformData(incomingData);

        if (interceptedData != null) {
          _data = interceptedData;
        } else {
          _data = incomingData;
        }

        onData(_data);
        notifyListeners();
      },
      onError: (error) {
        setError(error);
        _error = error;
        _data = null;
        onError(error);
        notifyListeners();
      },
    );

    onSubscribed();
    changeSource = false;
  }

  /// Called before the notifyListeners is called when data has been set.
  void onData(T data) {}

  /// Called when the stream is listened too.
  void onSubscribed() {}

  /// Called when an error is fired in the stream.
  void onError(error) {}

  void onCancel() {}

  /// Called before the data is set for the presenter.
  T transformData(T data) {
    return data;
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    onCancel();

    super.dispose();
  }
}

class StreamData<T> extends _SourcePresenter<T> {
  Stream<T> stream;

  /// Called when the new data arrives
  ///
  /// notifyListeners is called before this so no need to call in here unless you're
  /// running additional logic and setting a separate value.
  Function onData;

  /// Called after the stream has been listened to.
  Function onSubscribed;

  /// Called when an error is placed on the stream.
  Function onError;

  /// Called when the stream is cancelled.
  Function onCancel;

  /// Allows you to modify the data before it's set as the new data for the presenter.
  /// This can be used to modify the data if required. If nothing is returned the data will not be set.
  Function transformData;

  StreamData(
    this.stream, {
    this.onData,
    this.onSubscribed,
    this.onError,
    this.onCancel,
    this.transformData,
  });

  StreamSubscription _streamSubscription;

  void initialize() {
    _streamSubscription = stream.listen(
      (incomingData) {
        setError(null);
        _error = null;
        notifyListeners();
        // Extra security in case transformData is not sent.
        var interceptedData =
            transformData == null ? incomingData : transformData(incomingData);

        if (interceptedData != null) {
          _data = interceptedData;
        } else {
          _data = incomingData;
        }

        notifyListeners();
        onData(_data);
      },
      onError: (error) {
        setError(error);
        _data = null;
        onError(error);
        notifyListeners();
      },
    );

    onSubscribed();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    onCancel();

    super.dispose();
  }
}

/// Interface: Additional actions that should be implemented by specialized presenters.
abstract class Initializable {
  void initialize();
}
