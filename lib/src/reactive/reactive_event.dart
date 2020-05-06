import 'dart:async';
import 'package:isotope/src/reactive/reactive.dart';
import 'package:isotope/src/reactive/reactive_value.dart';

/// Emits events of type [T]
abstract class Emitter<T> {
  factory Emitter() => StreamBackedEmitter<T>();
  /// Calls [callback] whenever there is an event
  void on(/* Callback | ValueCallback */ callback);
  /// Calls [callback] whenever there is an event. Returns a [StreamSubscription]
  /// to control the listening.
  StreamSubscription<T> listen(/* Callback | ValueCallback */ callback);
  /// Returns events as [Stream].
  Stream<T> get asStream;
  /// Pipes events to [other]
  void pipeTo(Emitter<T> other);
  /// Pipes events to [other]
  void pipeToValue(ReactiveValue<T> other);
  /// Emits a [value]
  void emitOne(T value);
  /// Emits all of the [values]
  void emitAll(Iterable<T> values);
  /// Emits values of the [stream]
  void emitStream(Stream<T> stream);
  /// Emits values of [emitter]
  void emit(Emitter<T> emitter);
  /// Emits values of [value]
  void emitReactiveValue(ReactiveValue<T> value);
}

class StreamBackedEmitter<T> implements Emitter<T> {
  final _streamer = StreamController<T>();

  Stream<T> _stream;

  StreamBackedEmitter() {
    _stream = _streamer.stream.asBroadcastStream();
  }

  void emitOne(T value) => _streamer.add(value);

  void emitAll(Iterable<T> values) {
    for (T v in values) _streamer.add(v);
  }

  void emitStream(Stream<T> stream) => _streamer.addStream(stream);

  void on(/* Callback | ValueCallback */ callback) {
    if (callback is ReactiveCallback)
      _stream.listen((_) => callback());
    else if (callback is ReactiveValueCallback<T>)
      _stream.listen(callback);
    else
      throw new Exception('Invalid callback ${callback}!');
  }

  StreamSubscription<T> listen(/* Callback | ValueCallback */ callback) {
    if (callback is ReactiveCallback)
      return _stream.listen((_) => callback());
    else if (callback is ReactiveValueCallback<T>) return _stream.listen(callback);
    throw new Exception('Invalid callback!');
  }

  void emit(Emitter<T> emitter) => emitter.listen(emitOne);

  Stream<T> get asStream => _stream;

  void pipeTo(Emitter<T> emitter) => emitter.emit(this);

  void pipeToValue(ReactiveValue<T> other) => other.bindStream(_stream);

  void emitReactiveValue(ReactiveValue<T> value) {
    _streamer.addStream(value.values);
  }
}
