import 'package:collection/collection.dart';
import 'package:isotope/src/reactive/reactive.dart';

class ReactiveMap<K, V> extends DelegatingMap<K, V> implements Map<K, V> {
  ReactiveMap() : super(<K, V>{});

  ReactiveMap.from(Map other) : super(Map<K, V>.from(other));

  ReactiveMap.of(Map<K, V> other) : super(Map<K, V>.of(other));

  ReactiveMap.fromIterable(Iterable iterable, {K key(element), V value(element)})
      : super(Map<K, V>.fromIterable(iterable, key: key, value: value));

  ReactiveMap.fromIterables(Iterable<K> keys, Iterable<V> values)
      : super(Map<K, V>.fromIterables(keys, values));

  ReactiveMap.fromEntries(Iterable<MapEntry<K, V>> entries)
      : super(Map<K, V>.fromEntries(entries));

  void add(K key, V value) => this[key] = value;

  void addIf(/* bool | Condition */ condition, K key, V value) {
    if (condition is ReactiveCondition) condition = condition();
    if (condition is bool && condition) this[key] = value;
  }

  void addAllIf(/* bool | Condition */ condition, Map<K, V> values) {
    if (condition is ReactiveCondition) condition = condition();
    if (condition is bool && condition) addAll(values);
  }
}
