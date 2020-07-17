import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

/// An implementation of the PresenterWidget that allows you to use Hooks in the build.
abstract class HookPresenterWidget<T> extends HookWidget {
  final bool reactive;
  HookPresenterWidget({Key key, this.reactive = true});

  @override
  Widget build(BuildContext context) =>
      buildPresenterWidget(context, Provider.of<T>(context, listen: reactive));

  Widget buildPresenterWidget(BuildContext context, T viewModel);
}
