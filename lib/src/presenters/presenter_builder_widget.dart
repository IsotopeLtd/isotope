import 'package:flutter/widgets.dart';
import 'package:isotope/src/presenters/presenter_builder.dart';

/// A widget that wraps the [PresenterBuilder] class in a less boiler plate use of 
/// the widget. Default [reactive] value is true. Can be overridden and set to false.
abstract class PresenterBuilderWidget<T extends ChangeNotifier> extends StatelessWidget {
  const PresenterBuilderWidget({Key key}) : super(key: key);

  /// A function that builds the UI to be shown from the Presenter - Required.
  ///
  /// [presenter] is the Presenter passed in and [child] is the [staticChildBuilder] result.
  Widget builder(
    BuildContext context,
    T presenter,
    Widget child,
  );

  /// A builder that builds the Presenter for this UI - Required.
  T presenterBuilder(BuildContext context);

  /// Indicates if the [builder] should be rebuilt when notifyListeners
  /// is called. When reactive is false the builder will fire once and 
  /// the widgets will be used as a static child. IT WILL NOT BE BUILT AGAIN.
  bool get reactive => true;

  /// When set to true a new Presenter will be constructed everytime 
  /// the widget is inserted. When setting this to true make sure to handle 
  /// all disposing of streams if subscribed to any in the Presenter. 
  /// [onPresenterReady] will fire once the presenter has been created/set.
  /// This will be used when on re-insert of the widget the presenter has 
  /// to be constructed with a new value.
  bool get createNewPresenterOnInsert => false;

  /// Indicates if you want Provider to dispose the presenter when it is 
  /// removed from the widget tree. Default is true.
  bool get disposePresenter => true;

  /// Fires when the presenter is first created or recreated. This will fire 
  /// multiple times when [createNewPresenterOnInsert] is set to true.
  void onPresenterReady(T presenter) {}

  /// A Function that builds UI for the static child that builds only once
  ///
  /// When [reactive] is set to false the builder is used as the static child
  /// and is only ever built once.
  Widget staticChildBuilder(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    if (reactive) {
      return PresenterBuilder<T>.reactive(
        builder: builder,
        presenterBuilder: () => presenterBuilder(context),
        staticChild: staticChildBuilder != null ? staticChildBuilder(context) : null,
        onPresenterReady: onPresenterReady,
        disposePresenter: disposePresenter,
        createNewPresenterOnInsert: createNewPresenterOnInsert,
      );
    } else {
      return PresenterBuilder<T>.nonReactive(
        builder: builder,
        presenterBuilder: () => presenterBuilder(context),
        onPresenterReady: onPresenterReady,
        disposePresenter: disposePresenter,
        createNewPresenterOnInsert: createNewPresenterOnInsert,
      );
    }
  }
}
