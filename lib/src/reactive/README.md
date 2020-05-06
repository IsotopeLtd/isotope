# Reactive

Write elegant reactive cross-platform client side applications using observable states and event emitters. 

Provides:

- `ReactiveValue`
- `ReactiveList`
- `ReactiveSet`
- `ReactiveMap`
- `ReactiveEvent` (Emitter)

## Philosophy

Reactive provides a light-weight non-intrusive reactive framework to build cross-platform UI. It uses Dart's asynchronous `Stream`s to emit and listen to changes.

Various observable types like `ReactiveValue`, `ReactiveList`, `ReactiveSet` and `ReactiveMap` can be used to update UI automatically on changes. `ReactiveEvent`s can be passed up the widget tree using event `Emmitter`.

## Reactive values

`ReactiveValue` can be used to encapsulate a simple observable value. 

### Getting and setting value

`Reactive` exposes field `value` to get and set the current value. 


```dart
main() {
  final num = ReactiveValue<int>(initial: 5);
  int got = num.value; // Gets current value
  num.value = 10;      // Sets current value
}
```

When a value that is different from the existing value is set, the change is notified through various methods explained in the next section.

### Listening to changes

Reactive provides few flexible methods to listen to changes:

1. `onChange`: Record of changes
2. `values`: Stream of new values
3. `listen`: Callback function with new value

```dart
main() {
  final num = ReactiveValue<int>(initial: 5);
  print(num.value);  // => 5
  num.values.listen((int v) => print(v));  // => 5, 20, 25
  num.value = 20;
  num.value = 25;
}
```

### Binding to a value

Binding a `ReactiveValue` to a `Stream` (using method `bindStream`) or another `ReactiveValue` 
(using method `bind`) changes its value when the source `Stream` emits or `ReactiveValue` changes. This is very useful in scenarios where one would like to change a model's value or widget's property when control changes. For example, change a text field's value when a checkbox is toggled.

```dart
  textBox.value.bindStream(checkBox.checked.map((bool v) => v?'Female': 'Male'));
```

### Full examples

```dart
main() {
  final num = ReactiveValue<int>(initial: 5);
  print(num.value);  // => 5
  num.value = 10;
  num.value = 15;
  num.values.listen((int v) => print(v));  // => 15, 20, 25
  num.value = 20;
  num.value = 25;
}
```

## Composite reactive objects

Reactive is designed to be non-intrusive. The philosophy is to separate the model and its reactive cousin into different classes.

```dart
class ReactiveUser {
  final name = ReactiveValue<String>();
  final age = ReactiveValue<int>();
}

class User {
  final rx = ReactiveUser();

  User({String name, int age}) {
    this.name = name;
    this.age = age;
  }

  String get name => rx.name.value;
  set name(String value) => rx.name.value = value;

  int get age => rx.age.value;
  set age(int value) => rx.age.value = value;
}

main() {
  final user = User(name: 'Messi', age: 30);
  user.age = 31;
  print(user.age);  // => 31
  print('---------');
  user.age = 32;
  user.rx.age.listen((int v) => print(v));  // => 20, 25
  user.age = 33;
  user.age = 34;
  user.age = 35;
}
```

## Event emitter

`Emitter`s provide a simple interface to emit and listen to events. It is designed to inter-operate with `ReactiveValue` to provide maximum productivity.

### Listening to an event

1. `on`: Execute callback on event
2. `listen`: Similar to Stream
3. `asStream`: Obtain event as Stream

### Piping events

`pipeTo` pipes events to another `Emitter`.

`pipeToValue` pipes events to the given `ReactiveValue`. This could be very helpful in binding events to observable values.

### Emitting events

`emit`, `emitOne`, `emitAll`, `emitStream` and `emitReactiveValue` provides various ways to emit events using the `Emitter`

## Reactive Lists

`ReactiveList` notifies changes (addition, removal, clear, setting) of its elements.

### Updating ReactiveList

`ReactiveList` implements Dart's `List`. 

Besides `List`'s methods, `ReactiveList` provides convenient methods like `addIf` and `addAllIf` 
to add elements based on a condition.

```dart
main() {
  final nums = ReactiveList<int>();
  nums.onChange.listen((c) => print(c.element)); // => 5
  nums.addIf(5 < 10, 5);
  nums.addIf(5 > 9, 9);
}
```

Use `assign` and `assignAll` methods to replace existing contents of the list with new content.

### Listening for changes

`onChange` exposes a `Stream` of record of changes of the `List`.

## Reactive Sets

`ReactiveSet` notifies changes (addition and removal) of its elements.

### Updating `ReactiveSet` notifies changes (addition and removal) of its elements.

`ReactiveSet` implements Dart's `Set`. 

Besides `Set`'s methods, `ReactiveSet` provides convenient methods like `addIf` and `addAllIf` 
to add elements based on a condition.

```dart
main() {
  final nums = ReactiveSet<int>();
  nums.onChange.listen((c) => print(c.element)); // => 5
  nums.addIf(5 < 10, 5);
  nums.addIf(5 > 9, 9);
}
```

### Listening for changes

`onChange` exposes a `Stream` of record of change of the `Set`.

### Binding

`bindBool` and `bindBoolValue` allows removing or adding the given element based on the `Stream` of `bool`s or `ReactiveValue` of `bool`s.

`bindOneByIndexStream` and `bindOneByIndex` allows removing all but the one element from a given `Iterable` of elements based on index `Stream` or `ReactiveValue`.

## Reactive Maps

`ReactiveMap` notifies changes (addition, removal, clear, setting) of its elements.

### Updating ReactiveMap

`ReactiveMap` implements Dart's `Map`. 

Besides `Map`'s methods, `ReactiveMap` provides convenient methods like `addIf` and `addAllIf` to add elements based on a condition.

### Listening for changes

`onChange` exposes a `Stream` of record of changes of the `Map`.
