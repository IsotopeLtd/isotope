# ViewModels

This architecture was initially a version of MVVM. It aims to provide **common functionalities to make app development easier** as well as code principles to use during development to ensure your code stays maintainable.

## Installation

Add `isotope` as a dependency in your `pubspec.yaml` file.

```
responsive:
  git: git://github.com/isotopestudio/isotope.git
```

## Usage

Import the `isotope/view_models.dart` library:

```dart
import 'package:isotope/view_models.dart';
```

## How does it work

The architecture is very simple. It consists of 3 major pieces, everything else is up to your implementation style. These pieces are:

- **View**: Shows the UI to the user. Single widgets also qualify as views (for consistency in terminology) a view in this case is not a "Page" it's just a UI representation.
- **ViewModel**: Manages the state of the View, business logic and any other logic as required from user interaction. It does this by making use of the services
- **Services**: A wrapper of a single functionality / feature set. This is commonly used to wrap things like showing a dialog, wrapping database functionality, integrating an api, etc.
- **Managers**: (Suggested) A service that requires other services. This piece serves no particular part in the architecture except for indicating that it has dependencies on other services. It's main purpose is to distinguish between services that depend on other services and ones that don't. It's not a hard rule to follow but will allow for more code separation.

Lets go over some of those principles to follow during development.

- Views should never MAKE USE of a service directly.
- Views should contain zero to (preferred) no logic. If the logic is from UI only items then we do the least amount of required logic and pass the rest to the ViewModel.
- Views should ONLY render the state in its ViewModel.
- ViewModels for widgets that represent page views are bound to a single View only.
- ViewModels may be re-used if the UI required the exact same functionality.
- ViewModels should not know about other ViewModels

## Architecture

ViewModels provides you with classes and functionality to make it easy to implement a MVVM-like architecture,  including navigation, dependency injection, service location, error handling, etc.

## ViewModelBuilder

The `ViewModelBuilder` is used to create the "binding" between a ViewModel and the View. There is no two-way binding in this architecture, which is why it is not a strict MVVM implementation. The `ViewModelBuilder` wraps up all the `ChangeNotifierProvider` code which allows us to trigger a rebuild of a widget when calling `notifyListeners` within the ViewModel.

A ViewModel is simply a dart class that extends `ChangeNotifier`. The `ViewModelBuilder` has 2 constructors, one that's `.reactive` and one that's not. The `.nonReactive` constructor is for UI that does not require the builder to fire when notifyListeners is called in the ViewModel. The nonReactive construction was designed to reduce the boilerplate when the same data has to go to multiple widgets using the same ViewModel. This is very prominent when using the responsive_builder package.

### Reactive

This is the default implementation of "binding" your view to your ViewModel.

```dart

// View
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using the reactive constructor gives you the traditional viewmodel
    // binding which will excute the builder again when notifyListeners is called.
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) => model.initialise(),
      builder: (context, model, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            model.updateTitle();
          },
        ),
        body: Center(
          child: Text(model.title),
        ),
      ),
    );
  }
}

// ViewModel
class HomeViewModel extends ChangeNotifier {
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

When `notifyListeners` is called in the ViewModel the builder is triggered allowing you to rebuild your UI with the new updated ViewModel state. The process here is you update your data then call `notifyListeners` and rebuild your UI.

### Non Reactive

The `.nonReactive` constructor is best used for providing your ViewModel to multiple child widgets that will make use of it. It was created to make it easier to build and provide the same ViewModel to multiple UI's. Here's a simple example.

```dart
// Viewmodel in the above code

// View
class HomeViewMultipleWidgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.nonReactive(
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) => model.initialise(),
      builder: (context, model, _) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            model.updateTitle();
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

class TitleSection extends ViewModelWidget<HomeViewModel> {
  @override
  Widget build(BuildContext context, HomeViewModel model) {
    return Row(
      children: <Widget>[
        Text(
          'Title',
          style: TextStyle(fontSize: 20),
        ),
        Container(
          child: Text(model.title),
        ),
      ],
    );
  }
}

class DescriptionSection extends ViewModelWidget<HomeViewModel> {
  @override
  Widget build(BuildContext context, HomeViewModel model) {
    return Row(
      children: <Widget>[
        Text(
          'Description',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Container(
          child: Text(model.title),
        ),
      ],
    );
  }
}
```

So what we're doing here is providing the ViewModel to the children of the builder function. The builder function itself won't retrigger when `notifyListeners` is called. Instead we will extend from `ViewModelWidget` in the widgets that we want to rebuild from the ViewModel. This allows us to easily access the ViewModel in multiple widgets without a lot of repeat boilerplate code. We already extend from a `StatelessWidget` so we can change that to `ViewModelWidget`. Then we simply add the ViewModel as a parameter to the build function. This is the same as calling `Provider<ViewModel>.of` in every widget we want to rebuild.

### ViewModelBuilderWidget

If you want to make use of the `ViewModelBuilder` directly as a widget is can be extended as well using the `ViewModelBuilderWidget<T>`. This will give you the same properties to override as the ones you can pass into the named constructors. There are 2 required overrides, the same as the 2 required parameters for the constructors. The difference with this is that your code will look like a normal widget so it fits into the code base. You can also override and implement `onModelReady` and `staticChildBuilder`.

```dart
class BuilderWidgetExampleView extends ViewModelBuilderWidget<HomeViewModel> {
  @override
  bool get reactive => false;

  @override
  bool get createNewModelOnInsert => false;

  @override
  bool get disposeViewModel => true;

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel model,
    Widget child,
  ) {
    return Scaffold(
      body: Center(
        child: Text(model.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => model.updateTitle(),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
```

This is to help with removing some boilerplate code.

### Disable ViewModel Dispose

An example of how to disable the dispose for a viewmodel.

```dart
// View
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.withConsumer(
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) => model.initialise(),
      // When the disposeViewModel is set to false the viewmodel will
      // not be disposed during the normal life cycle of a widget.
      disposeViewModel: false,
      builder: (context, model, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            model.updateTitle();
          },
        ),
        body: Center(
          child: Text(model.title),
        ),
      ),
    );
  }
}

```

Note that the `ViewModelBuilder` constructor is called with parameter `disposeViewModel: false`. This enables us to pass an existing instance of a viewmodel.

## ViewModel Widget

The `ViewModelWidget` is an implementation of a widget class that returns a value provided by Provider as a parameter in the build function of the widget. Lets say for instance you have a data model you want to use in multiple widgets. We can use the `Provider.value` call to supply that value, then inside the multiple widgets we inherit from the `ViewModelWidget` and make use of the data directly from the build method.

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
class FullNameWidget extends ViewModelWidget<Human> {
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
class DuplicateNameWidget extends ViewModelWidget<Human> {
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

### Non reactive ViewModelWidget

Sometimes you want a widget to have access to the ViewModel but you don't want it to rebuild when notifyListeners is called. In this case you can set the reactive value to false for the super constructor of the `ViewModelWidget`. This is commonly used in widgets that don't make use of the models state and only it's functionality.

```dart
class UpdateTitleButton extends ViewModelWidget<HomeViewModel> {
  UpdateTitleButton({
    Key key,
  }) : super(key: key, reactive: false);

  @override
  Widget build(BuildContext context, model) {
    return FloatingActionButton(
      onPressed: () {
        model.updateTitle();
      },
    );
  }
}
```

## BaseViewModel functionality

This is a `ChangeNotifier` with busy state indication functionality. This allows you to set a busy state based on an object passed it. This will most likely be the properties on the extended ViewModel. It came from the need to have busy states for multiple values in the same ViewModels without relying on implicit state values. It also contains a helper function to indicate busy while a future is executing. This way we avoid having to call setBusy before and after every Future call.

To use the `BaseViewModel` you can extend it and make use of the busy functionality as follows.

```dart
class WidgetOneViewModel extends BaseViewModel {
  Human _currentHuman;
  Human get currentHuman => _currentHuman;

  void setBusyOnProperty() {
    setBusyForObject(_currentHuman, true);
    // Fetch updated human data
    setBusyForObject(_currentHuman, false);
  }

  void setModelBusy() {
    setBusy(true);
    // Do things here
    setBusy(false);
  }

  Future longUpdateStuff() async {
    // Sets busy to true before starting future and sets it to false after executing
    // You can also pass in an object as the busy object. Otherwise it'll use the model
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
    return ViewModelBuilder<WidgetOneViewModel>.reactive(
      viewModelBuilder: () => WidgetOneViewModel(),
      builder: (context, model, child) => GestureDetector(
        onTap: () => model.longUpdateStuff(),
        child: Container(
          width: 100,
          height: 100,
          // Use isBusy to check if the model is set to busy
          color: model.isBusy ? Colors.green : Colors.red,
          alignment: Alignment.center,
          // A bit silly to pass the same property back into the viewmodel
          // but here it makes sense
          child: model.busy(model.currentHuman)
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

All the major functionality for the BaseViewModel is shown above

## Reactivity

One thing that was common a scenario with the first implementation of this architecture that was clearly lacking is reacting to values changed by different ViewModels. I don't have the exact implementation that I would hope for but without reflection some things will have to be a bit more verbose. The stacked architecture makes provision for ViewModels to react to changes to values in a service by making use of RxValue from the [Observable-Ish](https://pub.dev/packages/observable_ish) package.

### Reactive Service Mixin

In the stacked library we have a `ReactiveServiceMixin` which can be used to register values to "react" to. When any of these values change the listeners registered with this service will be notified to update their UI. This is definitely not the most effecient way but I have tested this with 1000 widgets with it's own viewmodel all updating on the screen and it works fine. If you follow general good code implementations and layout structuring you will have no problem keeping your app at 60fps no matter the size.

There are three things you need to make a service reactive.

1. Use the `ReactiveServiceMixin` with the service you want to make reactive
2. Wrap your values in an RxValue. The value provided by Observable-ish
3. Register your reactive values by calling `listenToReactiveValues`. A function provided by the mixin.

Below is some source code for the non theory coders out there like myself.

```dart
class InformationService with ReactiveServiceMixin { //1
  InformationService() {
    //3
    listenToReactiveValues([_postCount]);
  }

  //2
  RxValue<int> _postCount = RxValue<int>(initial: 0);
  int get postCount => _postCount.value;

  void updatePostCount() {
    _postCount.value++;
  }

  void resetCount() {
    _postCount.value = 0;
  }
}
```

Easy peasy. This service can now be listened too when any of the properties passed into the `listenToReactiveValues` is changed. So how do listen to these values? I'm glad you asked. Lets move onto the `ReactiveViewModel`.

### Reactive View Model

This ViewModel extends the `BaseViewModel` and adds an additional function that allows you to listen to services that are being used in the model. There are two thing you have to do to make a ViewModel react to changes in a service.

1. Extend from `ReactiveViewModel`.
2. Implement reactiveServices getter that return a list of reactive services.

```dart
class WidgetOneViewModel extends ReactiveViewModel {
  // You can use get_it service locator or pass it in through the constructor
  final InformationService _informationService = locator<InformationService>();

   @override
  List<ReactiveServiceMixin> get reactiveServices => [_informationService];
}
```

That's it. To see a full example take a look at the example in the git repo.

### StreamViewModel

This `ViewModel` extends the `BaseViewModel` and provides functionality to easily listen and react to stream data. It allows you to supply a `Stream` of type `T` which it will subscribe to, manage subscription (dispose when done) and give you callbacks where you can modify / manipulate the data. It will automatically rebuild the `ViewModel` as new stream values come in. It has 1 required override which is the stream getter and 4 optional overrides.

- **stream**: Returns the `Stream` you would like to listen to
- **onData**: Called after the view has rebuilt and provides you with the data to use
- **onCancel**: Called after the stream has been disposed
- **onSubscribed**: Called when the stream has been subscribed to
- **onError**: Called when an error is sent over the stream

```dart
// ViewModel
class StreamCounterViewModel extends StreamViewModel<int> {
  String get title => 'This is the time since epoch in seconds \n $data';

  @override
  Stream<int> get stream => locator<EpochService>().epochUpdatesNumbers();
}

// View
class StreamCounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StreamCounterViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
            body: Center(
              child: Text(model.title),
            ),
          ),
      viewModelBuilder: () => StreamCounterViewModel(),
    );
  }
}

// Service (registered using injectable, NOT REQUIRED)
@lazySingleton
class EpochService {
  Stream<int> epochUpdatesNumbers() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield DateTime.now().millisecondsSinceEpoch;
    }
  }
}
```

The code above will listen to a stream and provide you the data to rebuild with. You can create a `ViewModel` that listens to a stream with two lines of code.

```dart
class StreamCounterViewModel extends StreamViewModel<int> {
  @override
  Stream<int> get stream => locator<EpochService>().epochUpdatesNumbers();
}
```

Besides having the onError function you can override the `ViewModel` will also set the hasError property to true for easier checking on the view side. The `onError` callback can be used for running additional actions on failure and the `hasError` property should be used when you want to show error specific UI.

### FutureViewModel

This `ViewModel` extends the `BaseViewModel` to provide functionality to easily listen to a Future that fetches data. This requirement came off a Details view that has to fetch additional data to show to the user after selecting an item. When you extend the `FutureViewModel` you can provide a type which will then require you to override the future getter where you can set the future you want to run.

The future will run after the model has been created automatically.

```dart
class FutureExampleViewModel extends FutureViewModel<String> {
  @override
  Future<String> get future => getDataFromServer();

  Future<String> getDataFromServer() async {
    await Future.delayed(const Duration(seconds: 3));
    return 'This is fetched from everywhere';
  }
}
```

This will automatically set the view's isBusy property and will indicate false when it's complete. It also exposes have a `dataReady` property that can be used. This will indicate true when the data is available. The `ViewModel` can be used in a view as follows.

```dart
class FutureExampleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FutureExampleViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: Center(
          // model will indicate busy until the future is fetched
          child: model.isBusy ? CircularProgressIndicator() : Text(model.data),
        ),
      ),
      viewModelBuilder: () => FutureExampleViewModel(),
    );
  }
}
```

The `FutureViewModel` will also catch an error and indicate that it has received an error through the `hasError` property. You can also override the onError function if you want to receive that error and perform a specific action at that point.

```dart
class FutureExampleViewModel extends FutureViewModel<String> {
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
    return ViewModelBuilder<FutureExampleViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: model.hasError
            ? Container(
                color: Colors.red,
                alignment: Alignment.center,
                child: Text(
                  'An error has occered while running the future',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Center(
                child: model.isBusy
                    ? CircularProgressIndicator()
                    : Text(model.data),
              ),
      ),
      viewModelBuilder: () => FutureExampleViewModel(),
    );
  }
}
```

### MultipleFutureViewModel

In addition to being able to run a Future you also make a view react to data returned from multiple futures. It requires you to provide a map of type string along with a Function that returns a Future that will be executed after the `ViewModel` has been constructed. See below for an example of using a `MultipleFutureViewModel`.

```dart
import 'package:stacked/stacked.dart';

const String _NumberDelayFuture = 'delayedNumber';
const String _StringDelayFuture = 'delayedString';

class MultipleFuturesExampleViewModel extends MultipleFutureViewModel {
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
class MultipleFuturesExampleView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MultipleFuturesExampleViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
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
                    child: model.fetchingNumber
                        ? CircularProgressIndicator()
                        : Text(model.fetchedNumber.toString()),
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
                    child: model.fetchingString
                        ? CircularProgressIndicator()
                        : Text(model.fetchedString),
                  ),
                ],
              ),
            ),
          ),
      viewModelBuilder: () => MultipleFuturesExampleViewModel());
  }
}
```

### HookViewModelWidget

The `HookViewModelWidget` allows you to make use of Flutter Hooks inside the build function. This is very useful when you want to use `TextEditing` controllers and you're implementing this architecture.

```dart
// View that creates and provides the viewmodel
class HookViewModelWidgetExample extends StatelessWidget {
  const HookViewModelWidgetExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.nonReactive(
      builder: (context, model, child) => Scaffold(
          body: Center(
        child: _HookForm(),
      )),
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}

// Form that makes use of the ViewModel provided above but also makes use of hooks
class _HookForm extends HookViewModelWidget<HomeViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel model) {
    var title = useTextEditingController();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(model.title),
        TextField(
          controller: title,
          onChanged: model.updateTile,
        )
      ],
    );
  }
}

// ViewModel
class HomeViewModel extends BaseViewModel {
  String title = 'default';

  void updateTile(String value) {
    title = value;
    notifyListeners();
  }
}
```