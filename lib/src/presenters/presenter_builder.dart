import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:isotope/src/presenters/presenter.dart';

enum _PresenterBuilderType { NonReactive, Reactive }

/// A widget that provides base functionality for the 
/// View -> Presenter -> Model provider architecture.
class PresenterBuilder<T extends ChangeNotifier> extends StatefulWidget {
  final Widget staticChild;

  /// Fires once when the presenter is created or set for the first time. 
  /// If you want this to fire everytime the widget is inserted set 
  /// [createNewPresenterOnInsert] to true.
  final Function(T) onPresenterReady;

  /// Builder function with access to the presenter to build UI form.
  final Widget Function(BuildContext, T, Widget) builder;

  /// A builder function that returns the presenter for this widget.
  final T Function() presenterBuilder;

  /// Indicates if you want Provider to dispose the presenter when it's 
  /// removed from the widget tree. Default is true.
  final bool disposePresenter;

  /// When set to true a new Presenter will be constructed everytime the 
  /// widget is inserted.
  ///
  /// When setting this to true make sure to handle all disposing of 
  /// streams if subscribed to any in the presenter. [onPresenterReady] 
  /// will fire once the presenter has been created/set. This will be 
  /// used when on re-insert of the widget the presenter has to be 
  /// constructed with a new value.
  final bool createNewPresenterOnInsert;

  final _PresenterBuilderType providerType;

  /// Constructs a Presenter provider that will not rebuild the provided 
  /// widget when notifyListeners is called. Widget from [builder] will 
  /// be used as a static child and will not rebuild when notifyListeners 
  /// is called.
  PresenterBuilder.nonReactive({
    @required this.builder,
    @required this.presenterBuilder,
    this.onPresenterReady,
    this.disposePresenter = true,
    this.createNewPresenterOnInsert = false,
  })  : providerType = _PresenterBuilderType.NonReactive,
        staticChild = null;

  /// Constructs a presenter provider that fires the [builder] function when 
  /// notifyListeners is called in the presenter.
  PresenterBuilder.reactive({
    @required this.builder,
    @required this.presenterBuilder,
    this.staticChild,
    this.onPresenterReady,
    this.disposePresenter = true,
    this.createNewPresenterOnInsert = false,
  }) : providerType = _PresenterBuilderType.Reactive;

  @override
  _PresenterBuilderState<T> createState() => _PresenterBuilderState<T>();
}

class _PresenterBuilderState<T extends ChangeNotifier> extends State<PresenterBuilder<T>> {
  T _presenter;

  @override
  void initState() {
    super.initState();
    // We want to ensure that we only build the presenter if it has not 
    // been built yet.
    if (_presenter == null) {
      _createPresenter();
    }
    // Or if the user wants to create a new presenter whenever initState
    // is fired.
    else if (widget.createNewPresenterOnInsert) {
      _createPresenter();
    }
  }

  void _createPresenter() {
    if (widget.presenterBuilder != null) {
      _presenter = widget.presenterBuilder();
    }

    _initialiseSpecialPresenters();

    // Fire onPresenterReady after the presenter has been constructed.
    if (widget.onPresenterReady != null) {
      widget.onPresenterReady(_presenter);
    }
  }

  void _initialiseSpecialPresenters() {
    // Add any additional actions here for specialised presenters.
    if (_presenter is FuturePresenter) {
      (_presenter as FuturePresenter).runFuture();
    }

    if (_presenter is FuturesPresenter) {
      (_presenter as FuturesPresenter).runFutures();
    }

    if (_presenter is StreamPresenter) {
      (_presenter as StreamPresenter).initialise();
    }

    if (_presenter is StreamsPresenter) {
      (_presenter as StreamsPresenter).initialise();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.providerType == _PresenterBuilderType.NonReactive) {
      if (!widget.disposePresenter) {
        return ChangeNotifierProvider.value(
          value: _presenter,
          child: widget.builder(context, _presenter, widget.staticChild),
        );
      }

      return ChangeNotifierProvider(
        create: (context) => _presenter,
        child: widget.builder(context, _presenter, widget.staticChild),
      );
    }

    if (!widget.disposePresenter) {
      return ChangeNotifierProvider.value(
        value: _presenter,
        child: Consumer(
          builder: builderWithDynamicSourceInitialise,
          child: widget.staticChild,
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => _presenter,
      child: Consumer(
        builder: builderWithDynamicSourceInitialise,
        child: widget.staticChild,
      ),
    );
  }

  Widget builderWithDynamicSourceInitialise(BuildContext context, T presenter, Widget child) {
    if (presenter is DynamicSourcePresenter) {
      if (presenter.changeSource ?? false) {
        _initialiseSpecialPresenters();
      }
    }

    return widget.builder(context, presenter, child);
  }
}
