import 'dart:async';
import 'package:isotope/src/reactive/reactive.dart';
import 'package:isotope/src/reactive/reactive_stored_value.dart';
import 'package:isotope/src/reactive/reactive_proxy_value.dart';

/// Interface of an observable value of type [T]
abstract class ReactiveValue<T> {
  factory ReactiveValue({T initial}) => ReactiveStoredValue<T>(initial: initial);
  factory ReactiveValue.proxy({ReactiveValueGetter<T> getterProxy}) =>
      ReactiveProxyValue<T>(getterProxy: getterProxy);

  /// Get current value
  T get value;

  /// Set value
  set value(T val);

  /// Cast [val] to [T] before setting
  void setCast(dynamic /* T */ val);

  /// Stream of record of [Change]s of value
  Stream<Change<T>> get onChange;

  /// Stream of changes of value
  Stream<T> get values;

  /// Binds if [other] is [Stream] or [RxValue] of type [T]. Sets if [other] is
  /// instance of [T]
  void bindOrSet(/* T | Stream<T> | Reactive<T> */ other);

  /// Binds [other] to this
  void bind(ReactiveValue<T> other);

  /// Binds the [stream] to this
  void bindStream(Stream<T> stream);

  /// Calls [callback] with current value, when the value changes.
  StreamSubscription<T> listen(ReactiveValueCallback<T> callback);

  /// Maps the changes into a [Stream] of [R]
  Stream<R> map<R>(R mapper(T data));
}

/// A record of change in [RxValue]
class Change<T> {
  /// Value before change
  final T old;

  /// Value after change
  final T neu;
  final DateTime time;
  final int batch;
  Change(this.neu, this.old, this.batch, {DateTime time})
      : time = DateTime.now();
  String toString() => 'Change(new: $neu, old: $old)';
}
