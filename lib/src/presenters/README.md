# Presenters

This architecture aims to provide **common functionalities to make app development easier** as well as code principles to use during development to ensure your code stays maintainable. It uses a View -> Presenter -> Model architecture pattern which provides single-direction view binding from the presenter.

## Installation

Add `isotope` as a dependency in your `pubspec.yaml` file.

```
responsive:
  git: git://github.com/isotopestudio/isotope.git
```

## Usage

Import the `isotope/presenters.dart` library:

```dart
import 'package:isotope/presenters.dart';
```

## How does it work

The architecture is very simple. It consists of 3 major pieces, everything else is up to your implementation style. These pieces are:

- **View**: Shows the UI to the user. Single widgets also qualify as views (for consistency in terminology) a view in this case is not a "Page" it's just a UI representation.
- **Presenter**: Manages the state of the View, business logic and any other logic as required from user interaction. It does this by making use of the services.
- **Service**: A wrapper of a single functionality / feature set. This is commonly used to wrap things like showing a dialog, wrapping database functionality, integrating an API, etc.

_Optional:_
- **Manager**: A service that requires other services. This piece serves no particular part in the architecture except for indicating that it has dependencies on other services. It's main purpose is to distinguish between services that depend on other services and ones that don't. It's not a hard rule to follow but will allow for more code separation.

Lets go over some of those principles to follow during development.

- Views should never MAKE USE of a service directly.
- Views should contain zero logic. If the logic is from UI only items then we do the least amount of required logic and pass the rest to the Presenter.
- Views should ONLY render the state in its Presenter.
- Presenters for widgets that represent page views are bound to a single View only.
- Presenters may be reused if the UI requires the exact same functionality.
- Presenters should not know about other Presenters.

## Architecture

Presenters provides you with classes and functionality to make it easy to implement a single-direction data binding architecture, including navigation, dependency injection, service management, error handling, etc.

## PresenterBuilder

The `PresenterBuilder` is used to create the "binding" between a Presenter and the View. There is no two-way binding in this architecture, which is why it is not a MVVM implementation. The `PresenterBuilder` wraps up all the `ChangeNotifierProvider` code which allows us to trigger a rebuild of a widget when calling `notifyListeners` within the Presenter.

A presenter is simply a dart class that extends `ChangeNotifier`. The `PresenterBuilder` has 2 constructors, one that is `.reactive` and one that is not. The `.nonReactive` constructor is for UI that does not require the builder to fire when notifyListeners is called in the Presenter. The non-reactive construction was designed to reduce the boilerplate when the same data has to go to multiple widgets using the same presenter. This is very prominent when using the (responsive) views package.

### Reactive

This is the default implementation of "binding" your view to your presenter.

```dart

// View
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using the reactive constructor gives you the traditional presenter
    // binding which will excute the builder again when notifyListeners is called.
    return PresenterBuilder<HomePresenter>.reactive(
      presenterBuilder: () => HomePresenter(),
      onPresenterReady: (presenter) => presenter.initialise(),
      builder: (context, presenter, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            presenter.updateTitle();
          },
        ),
        body: Center(
          child: Text(presenter.title),
        ),
      ),
    );
  }
}

// Presenter
class HomePresenter extends Presenter {
  String title = 'default';

  void initialise() {
    title = 'initialised';
    notifyListeners();
  }

  int counter = 0;
  void updateTitle() {
    counter++;
    title = '$counter';
    notifyListeners();
  }
}

```

When `notifyListeners` is called in the Presenter, the builder is triggered allowing you to rebuild your UI with the new updated Presenter state. The process here is you update your data then call `notifyListeners` and rebuild your UI.

### Non-Reactive

The `.nonReactive` constructor is best used for providing your Presenter to multiple child widgets that will make use of it. It was created to make it easier to build and provide the same Presenter to multiple UIs. Here's a simple example.

```dart
// Presenter in the above code

// View
class HomeViewMultipleWidgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PresenterBuilder<HomePresenter>.nonReactive(
      presenterBuilder: () => HomePresenter(),
      onPresenterReady: (presenter) => presenter.initialise(),
      builder: (context, presenter, _) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            presenter.updateTitle();
          },
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[TitleSection(), DescriptionSection()],
        ),
      ),
    );
  }
}

class TitleSection extends PresenterWidget<HomePresenter> {
  @override
  Widget build(BuildContext context, HomePresenter presenter) {
    return Row(
      children: <Widget>[
        Text(
          'Title',
          style: TextStyle(fontSize: 20),
        ),
        Container(
          child: Text(presenter.title),
        ),
      ],
    );
  }
}

class DescriptionSection extends PresenterWidget<HomePresenter> {
  @override
  Widget build(BuildContext context, HomePresenter presenter) {
    return Row(
      children: <Widget>[
        Text(
          'Description',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Container(
          child: Text(presenter.title),
        ),
      ],
    );
  }
}
```

So what we're doing here is providing the Presenter to the children of the builder function. The builder function itself won't retrigger when `notifyListeners` is called. Instead we will extend from `PresenterWidget` in the widgets that we want to rebuild from the Presenter. This allows us to easily access the Presenter in multiple widgets without a lot of repeat boilerplate code. We already extend from a `StatelessWidget` so we can change that to `PresenterWidget`. Then we simply add the Presenter as a parameter to the build function. This is the same as calling `Provider<Presenter>.of` in every widget we want to rebuild.

### PresenterBuilderWidget

If you want to make use of the `PresenterBuilder` directly as a widget is can be extended as well using the `PresenterBuilderWidget<T>`. This will give you the same properties to override as the ones you can pass into the named constructors. There are 2 required overrides, the same as the 2 required parameters for the constructors. The difference with this is that your code will look like a normal widget so it fits into the code base. You can also override and implement `onPresenterReady` and `staticChildBuilder`.

```dart
class BuilderWidgetExampleView extends PresenterBuilderWidget<HomePresenter> {
  @override
  bool get reactive => false;

  @override
  bool get createNewPresenterOnInsert => false;

  @override
  bool get disposePresenter => true;

  @override
  Widget builder(
    BuildContext context,
    HomePresenter presenter,
    Widget child,
  ) {
    return Scaffold(
      body: Center(
        child: Text(presenter.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => presenter.updateTitle(),
      ),
    );
  }

  @override
  HomePresenter presenterBuilder(BuildContext context) => HomePresenter();
}
```

This is to help with removing some boilerplate code.

### Disable Presenter Dispose

An example of how to disable the dispose for a presenter.

```dart
// View
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PresenterBuilder<HomePresenter>.reactive(
      presenterBuilder: () => HomeVPresenter(),
      onPresenterReady: (presenter) => presenter.initialise(),
      // When the disposePresenter is set to false the presenter will
      // not be disposed during the normal life cycle of a widget.
      disposePresenter: false,
      builder: (context, presenter, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            presenter.updateTitle();
          },
        ),
        body: Center(
          child: Text(presenter.title),
        ),
      ),
    );
  }
}

```

Note that the `PresenterBuilder` constructor is called with parameter `disposePresenter: false`. This enables us to pass an existing instance of a presenter.

## Presenter Widget

The `PresenterWidget` is an implementation of a widget class that returns a value provided by Provider as a parameter in the build function of the widget. Lets say for instance you have a data model you want to use in multiple widgets. We can use the `Provider.value` call to supply that value, then inside the multiple widgets we inherit from the `PresenterWidget` and make use of the data directly from the build method.

```dart
// View
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Provider.value(
        value: Human(name: 'Dane', surname: 'Mackier'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[FullNameWidget(), DuplicateNameWidget()],
        ),
      ),
    );
  }
}

// Model
class Human {
  final String name;
  final String surname;

  Human({this.name, this.surname});
}

// consuming widget 1
class FullNameWidget extends PresenterWidget<Human> {
  @override
  Widget build(BuildContext context, Human model) {
    return Row(
      children: <Widget>[
        Container(
          child: Text(
            model.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        SizedBox(
          width: 50,
        ),
        Container(
          child: Text(
            model.surname,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
      ],
    );
  }
}

// consuming widget 2
class DuplicateNameWidget extends PresenterWidget<Human> {
  @override
  Widget build(BuildContext context, Human model) {
    return Row(
      children: <Widget>[
        Container(
          child: Text(model.name),
        ),
        SizedBox(
          width: 50,
        ),
        Container(
          child: Text(model.name),
        ),
      ],
    );
  }
}
```

### Non-Reactive PresenterWidget

Sometimes you want a widget to have access to the Presenter but you don't want it to rebuild when notifyListeners is called. In this case you can set the reactive value to false for the super constructor of the `PresenterWidget`. This is commonly used in widgets that don't make use of the models state and only its functionality.

```dart
class UpdateTitleButton extends PresenterWidget<HomePresenter> {
  UpdateTitleButton({Key key}) : super(key: key, reactive: false);

  @override
  Widget build(BuildContext context, presenter) {
    return FloatingActionButton(
      onPressed: () {
        presenter.updateTitle();
      },
    );
  }
}
```

## Presenter functionality

This is a `ChangeNotifier` with busy state indication functionality. This allows you to set a busy state based on an object passed it. This will most likely be the properties on the extended Presenter. It came from the need to have busy states for multiple values in the same presenters without relying on implicit state values. It also contains a helper function to indicate busy while a future is executing. This way we avoid having to call setBusy before and after every Future call.

To use the `Presenter` you can extend it and make use of the busy functionality as follows.

```dart
class WidgetOnePresenter extends Presenter {
  Human _currentHuman;
  Human get currentHuman => _currentHuman;

  void setBusyOnProperty() {
    setBusyForObject(_currentHuman, true);
    // Fetch updated human data
    setBusyForObject(_currentHuman, false);
  }

  void setPresenterBusy() {
    setBusy(true);
    // Do things here
    setBusy(false);
  }

  Future longUpdateStuff() async {
    // Sets busy to true before starting future and sets it to false after executing.
    // You can also pass in an object as the busy object. 
    // Otherwise it will use the presenter.
    var result = await runBusyFuture(updateStuff());
  }

  Future updateStuff() {
    return Future.delayed(const Duration(seconds: 3));
  }
}
```

This makes it convenient to use in the UI in a more readable manner.

```dart
class WidgetOne extends StatelessWidget {
  const WidgetOne({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PresenterBuilder<WidgetOnePresenter>.reactive(
      presenterBuilder: () => WidgetOnePresenter(),
      builder: (context, presenter, child) => GestureDetector(
        onTap: () => presenter.longUpdateStuff(),
        child: Container(
          width: 100,
          height: 100,
          // Use isBusy to check if the presenter is set to busy
          color: presenter.isBusy ? Colors.green : Colors.red,
          alignment: Alignment.center,
          // A bit silly to pass the same property back into the presenter
          // but here it makes sense
          child: presenter.busy(presenter.currentHuman)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(/* Human Details styling */)
        ),
      ),
    );
  }
}
```

All the major functionality for the Presenter is shown above.

## Reactivity

One thing that was common a scenario with the first implementation of this architecture that was clearly lacking is reacting to values changed by different presenters. I don't have the exact implementation that I would hope for but without reflection some things will have to be a bit more verbose. The presenter  architecture makes provision for presenters to react to changes to values in a service by making use of `ReactiveValue`.

### Reactive Service Mixin

In the presenters library we have a `ReactiveServiceMixin` which can be used to register values to "react" to. When any of these values change the listeners registered with this service will be notified to update their UI. This is definitely not the most effecient way but I have tested this with 1000 widgets with it's own presenter  all updating on the screen and it works fine. If you follow general good code implementations and layout structuring you will have no problem keeping your app at 60fps no matter the size.

There are three things you need to make a service reactive.

1. Use the `ReactiveServiceMixin` with the service you want to make reactive.
2. Wrap your values in an ReactiveValue.
3. Register your reactive values by calling `listenToReactiveValues`. A function provided by the mixin.

Below is some source code for the non-theory coders out there like myself.

```dart
class InformationService with ReactiveServiceMixin { //1
  InformationService() {
    //3
    listenToReactiveValues([_postCount]);
  }

  //2
  ReactiveValue<int> _postCount = ReactiveValue<int>(initial: 0);
  int get postCount => _postCount.value;

  void updatePostCount() {
    _postCount.value++;
  }

  void resetCount() {
    _postCount.value = 0;
  }
}
```

Easy peasy. This service can now be listened too when any of the properties passed into the `listenToReactiveValues` is changed. So how do listen to these values? I'm glad you asked. Let's move onto the `ReactivePresenter`.

### Reactive View Model

This presenter extends the `Presenter` and adds an additional function that allows you to listen to services that are being used in the model. There are two thing you have to do to make a presenter react to changes in a service.

1. Extend from `ReactivePresenter`.
2. Implement reactiveServices getter that return a list of reactive services.

```dart
class WidgetOnePresenter extends ReactivePresenter {
  // You can use Reistrar service manager or pass it in through the constructor.
  final InformationService _informationService = serviceManager<InformationService>();

   @override
  List<ReactiveServiceMixin> get reactiveServices => [_informationService];
}
```

### StreamPresenter

This presenter extends the `Presenter` and provides functionality to easily listen and react to stream data. It allows you to supply a `Stream` of type `T` which it will subscribe to, manage subscription (dispose when done) and give you callbacks where you can modify / manipulate the data. It will automatically rebuild the presenter as new stream values come in. It has 1 required override which is the stream getter and 4 optional overrides.

- **stream**: Returns the `Stream` you would like to listen to.
- **onData**: Called after the view has rebuilt and provides you with the data to use.
- **onCancel**: Called after the stream has been disposed.
- **onSubscribed**: Called when the stream has been subscribed to.
- **onError**: Called when an error is sent over the stream.

```dart
// Presenter
class StreamCounterPresenter extends StreamPresenter<int> {
  String get title => 'This is the time since epoch in seconds \n $data';

  @override
  Stream<int> get stream => serviceManager<EpochService>().epochUpdatesNumbers();
}

// View
class StreamCounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PresenterBuilder<StreamCounterPresenter>.reactive(
      builder: (context, presenter, child) => Scaffold(
            body: Center(
              child: Text(presenter.title),
            ),
          ),
      presenterBuilder: () => StreamCounterPresenter(),
    );
  }
}

class EpochService {
  Stream<int> epochUpdatesNumbers() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield DateTime.now().millisecondsSinceEpoch;
    }
  }
}
```

The code above will listen to a stream and provide you the data to rebuild with. You can create a `Presenter` that listens to a stream with two lines of code.

```dart
class StreamCounterPresenter extends StreamPresenter<int> {
  @override
  Stream<int> get stream => serviceManager<EpochService>().epochUpdatesNumbers();
}
```

Besides having the onError function you can override the `Presenter` will also set the hasError property to true for easier checking on the view side. The `onError` callback can be used for running additional actions on failure and the `hasError` property should be used when you want to show error specific UI.

### FuturePresenter

This presenter extends the `Presenter` to provide functionality to easily listen to a Future that fetches data. This requirement came off a Details view that has to fetch additional data to show to the user after selecting an item. When you extend the `FuturePresenter` you can provide a type which will then require you to override the future getter where you can set the future you want to run.

The future will run after the model has been created automatically.

```dart
class FutureExamplePresenter extends FuturePresenter<String> {
  @override
  Future<String> get future => getDataFromServer();

  Future<String> getDataFromServer() async {
    await Future.delayed(const Duration(seconds: 3));
    return 'This is fetched from everywhere';
  }
}
```

This will automatically set the view's isBusy property and will indicate false when it's complete. It also exposes have a `dataReady` property that can be used. This will indicate true when the data is available. The `Presenter` can be used in a view as follows.

```dart
class FutureExampleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PresenterBuilder<FutureExamplePresenter>.reactive(
      builder: (context, presenter, child) => Scaffold(
        body: Center(
          // model will indicate busy until the future is fetched
          child: presenter.isBusy ? CircularProgressIndicator() : Text(presenter.data),
        ),
      ),
      presenterBuilder: () => FutureExamplePresenter(),
    );
  }
}
```

The `FuturePresenter` will also catch an error and indicate that it has received an error through the `hasError` property. You can also override the onError function if you want to receive that error and perform a specific action at that point.

```dart
class FutureExamplePresenter extends FuturePresenter<String> {
  @override
  Future<String> get future => getDataFromServer();

  Future<String> getDataFromServer() async {
    await Future.delayed(const Duration(seconds: 3));
    throw Exception('This is an error');
  }

  @override
  void onError(error) {
  }
}
```

The hasError property can be used in the view the same way as the isBusy property.

```dart
class FutureExampleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PresenterBuilder<FutureExamplePresenter>.reactive(
      builder: (context, presenter, child) => Scaffold(
        body: presenter.hasError
            ? Container(
                color: Colors.red,
                alignment: Alignment.center,
                child: Text(
                  'An error has occered while running the future',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Center(
                child: presenter.isBusy
                    ? CircularProgressIndicator()
                    : Text(presenter.data),
              ),
      ),
      presenterBuilder: () => FutureExamplePresenter(),
    );
  }
}
```

### FuturesPresenter

In addition to being able to run a Future you also make a view react to data returned from multiple futures. It requires you to provide a map of type string along with a Function that returns a Future that will be executed after the `Presenter` has been constructed. See below for an example of using a `FuturesPresenter`.

```dart
import 'package:stacked/stacked.dart';

const String _NumberDelayFuture = 'delayedNumber';
const String _StringDelayFuture = 'delayedString';

class FuturesExamplePresenter extends FuturesPresenter {
  int get fetchedNumber => dataMap[_NumberDelayFuture];
  String get fetchedString => dataMap[_StringDelayFuture];

  bool get fetchingNumber => busy(_NumberDelayFuture);
  bool get fetchingString => busy(_StringDelayFuture);

  @override
  Map<String, Future Function()> get futuresMap => {
        _NumberDelayFuture: getNumberAfterDelay,
        _StringDelayFuture: getStringAfterDelay,
      };

  Future<int> getNumberAfterDelay() async {
    await Future.delayed(Duration(seconds: 2));
    return 3;
  }

  Future<String> getStringAfterDelay() async {
    await Future.delayed(Duration(seconds: 3));
    return 'String data';
  }
}
```

The data for the future will be in the `dataMap` when the future is complete. Each future will individually be set to busy using the key for the future passed in. With these functionalities you'll be able to show busy indicator for the UI that depends on the future's data while it's being fetched. There's also a `hasError` function which will indicate if the Future for a specific key has thrown an error.

```dart
class FuturesExampleView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PresenterBuilder<FuturesExamplePresenter>.reactive(
      builder: (context, presenter, child) => Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    color: Colors.yellow,
                    // Show busy for number future until the data is back or has failed
                    child: presenter.fetchingNumber
                        ? CircularProgressIndicator()
                        : Text(presenter.fetchedNumber.toString()),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    color: Colors.red,
                    // Show busy for string future until the data is back or has failed
                    child: presenter.fetchingString
                        ? CircularProgressIndicator()
                        : Text(presenter.fetchedString),
                  ),
                ],
              ),
            ),
          ),
      presenterBuilder: () => FuturesExamplePresenter());
  }
}
```

### HookPresenterWidget

The `HookPresenterWidget` allows you to make use of Flutter Hooks inside the build function. This is very useful when you want to use `TextEditing` controllers and you're implementing this architecture.

```dart
// View that creates and provides the viewmodel
class HookPresenterWidgetExample extends StatelessWidget {
  const HookPresenterWidgetExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PresenterBuilder<HomePresenter>.nonReactive(
      builder: (context, model, child) => Scaffold(
          body: Center(
        child: _HookForm(),
      )),
      presenterBuilder: () => HomePresenter(),
    );
  }
}

// Form that makes use of the Presenter provided above but also makes use of hooks
class _HookForm extends HookPresenterWidget<HomePresenter> {
  @override
  Widget buildPresenterWidget(BuildContext context, HomePresenter presenter) {
    var title = useTextEditingController();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(presenter.title),
        TextField(
          controller: title,
          onChanged: presenter.updateTile,
        )
      ],
    );
  }
}

// Presenter
class HomePresenter extends Presenter {
  String title = 'default';

  void updateTile(String value) {
    title = value;
    notifyListeners();
  }
}
```
