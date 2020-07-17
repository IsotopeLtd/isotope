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

  /// Indicates if the onPresenterReady should fire every time the model is inserted into the widget tree.
  /// Or only once during the lifecycle of the model.
  final bool fireOnPresenterReadyOnce;

  /// Indicates if we should run the initialize functionality for presenters only once.
  final bool initializeSpecialPresentersOnce;

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
    this.fireOnPresenterReadyOnce = false,
    this.initializeSpecialPresentersOnce = false,
    Key key,
  })  : providerType = _PresenterBuilderType.NonReactive,
        staticChild = null,
        super(key: key);

  /// Constructs a presenter provider that fires the [builder] function when
  /// notifyListeners is called in the presenter.
  PresenterBuilder.reactive({
    @required this.builder,
    @required this.presenterBuilder,
    this.staticChild,
    this.onPresenterReady,
    this.disposePresenter = true,
    this.createNewPresenterOnInsert = false,
    this.fireOnPresenterReadyOnce = false,
    this.initializeSpecialPresentersOnce = false,
    Key key,
  })  : providerType = _PresenterBuilderType.Reactive,
        super(key: key);

  @override
  _PresenterBuilderState<T> createState() => _PresenterBuilderState<T>();
}

class _PresenterBuilderState<T extends ChangeNotifier>
    extends State<PresenterBuilder<T>> {
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

    if (widget.initializeSpecialPresentersOnce &&
        !(_presenter as Presenter).initialized) {
      _initializeSpecialPresenters();
      (_presenter as Presenter)?.setInitialized(true);
    } else if (!widget.initializeSpecialPresentersOnce) {
      _initializeSpecialPresenters();
    }

    // Fire onPresenterReady after the presenter has been constructed.
    if (widget.onPresenterReady != null) {
      if (widget.fireOnPresenterReadyOnce &&
          !(_presenter as Presenter).onPresenterReadyCalled) {
        widget.onPresenterReady(_presenter);
        (_presenter as Presenter)?.setOnPresenterReadyCalled(true);
      } else if (!widget.fireOnPresenterReadyOnce) {
        widget.onPresenterReady(_presenter);
      }
    }
  }

  void _initializeSpecialPresenters() {
    // Add any additional actions here for specialized presenters.
    if (_presenter is Initializable) {
      (_presenter as Initializable).initialize();
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
          builder: builderWithDynamicSourceInitialize,
          child: widget.staticChild,
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => _presenter,
      child: Consumer(
        builder: builderWithDynamicSourceInitialize,
        child: widget.staticChild,
      ),
    );
  }

  Widget builderWithDynamicSourceInitialize(
      BuildContext context, T presenter, Widget child) {
    if (presenter is DynamicSourcePresenter) {
      if (presenter.changeSource ?? false) {
        _initializeSpecialPresenters();
      }
    }

    return widget.builder(context, presenter, child);
  }
}

/// EXPERIMENTAL: Returns the Presenter provided above this widget in the tree.
T getParentPresenter<T>(BuildContext context) => Provider.of<T>(context);
