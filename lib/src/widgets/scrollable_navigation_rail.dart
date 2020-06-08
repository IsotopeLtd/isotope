// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Modified by Jurgen Jocubeit 15 May 2020 to accomodate a scollable viewport
// for smaller screens (especially web target) using a LayoutBuilder which
// provides a BoxConstraints of the viewport. Also exposed destination
// padding & spacer properties for customization.

import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScrollableNavigationRail extends StatefulWidget {
  ScrollableNavigationRail({
    this.backgroundColor,
    this.extended = false,
    this.leading,
    this.trailing,
    @required this.destinations,
    @required this.selectedIndex,
    this.onDestinationSelected,
    this.elevation,
    this.groupAlignment,
    this.labelType,
    this.unselectedLabelTextStyle,
    this.selectedLabelTextStyle,
    this.unselectedIconTheme,
    this.selectedIconTheme,
    this.minWidth,
    this.minExtendedWidth,
    this.horizontalDestinationPadding = 8.0,
    this.verticalDestinationPaddingNoLabel = 24.0,
    this.verticalDestinationPaddingWithLabel = 16.0,
    this.verticalSpacer = const SizedBox(height: 8.0),
    this.roundedHighlight = false,
  }) :  assert(destinations != null && destinations.length >= 2),
        assert(selectedIndex != null),
        assert(0 <= selectedIndex && selectedIndex < destinations.length),
        assert(elevation == null || elevation > 0),
        assert(minWidth == null || minWidth > 0),
        assert(minExtendedWidth == null || minExtendedWidth > 0),
        assert((minWidth == null || minExtendedWidth == null) || minExtendedWidth >= minWidth),
        assert(extended != null),
        assert(!extended || (labelType == null || labelType == NavigationRailLabelType.none));

  final Color backgroundColor;
  final bool extended;
  final Widget leading;
  final Widget trailing;
  final List<NavigationRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final double elevation;
  final double groupAlignment;
  final NavigationRailLabelType labelType;
  final TextStyle unselectedLabelTextStyle;
  final TextStyle selectedLabelTextStyle;
  final IconThemeData unselectedIconTheme;
  final IconThemeData selectedIconTheme;
  final double minWidth;
  final double minExtendedWidth;
  final double horizontalDestinationPadding;
  final double verticalDestinationPaddingNoLabel;
  final double verticalDestinationPaddingWithLabel;
  final Widget verticalSpacer;
  final bool roundedHighlight;

  static Animation<double> extendedAnimation(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ExtendedNavigationRailAnimation>().animation;
  }

  @override
  _ScrollableNavigationRailState createState() => _ScrollableNavigationRailState();
}

class _ScrollableNavigationRailState extends State<ScrollableNavigationRail> with TickerProviderStateMixin {
  List<AnimationController> _destinationControllers = <AnimationController>[];
  List<Animation<double>> _destinationAnimations;
  AnimationController _extendedController;
  Animation<double> _extendedAnimation;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScrollableNavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.extended != oldWidget.extended) {
      if (widget.extended) {
        _extendedController.forward();
      } else {
        _extendedController.reverse();
      }
    }

    if (widget.destinations.length != oldWidget.destinations.length) {
      _resetState();
      return;
    }

    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _destinationControllers[oldWidget.selectedIndex].reverse();
      _destinationControllers[widget.selectedIndex].forward();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NavigationRailThemeData navigationRailTheme = NavigationRailTheme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    final Color backgroundColor = 
      widget.backgroundColor ?? navigationRailTheme.backgroundColor ?? theme.colorScheme.surface;
    final double elevation = widget.elevation ?? navigationRailTheme.elevation ?? 0;
    final double minWidth = widget.minWidth ?? _minRailWidth;
    final double minExtendedWidth = widget.minExtendedWidth ?? _minExtendedRailWidth;
    final Color baseSelectedColor = theme.colorScheme.primary;
    final Color baseColor = theme.colorScheme.onSurface.withOpacity(0.64);
    final IconThemeData defaultUnselectedIconTheme = 
      widget.unselectedIconTheme ?? navigationRailTheme.unselectedIconTheme;
    final IconThemeData unselectedIconTheme = IconThemeData(
      size: defaultUnselectedIconTheme?.size ?? 24.0,
      color: defaultUnselectedIconTheme?.color ?? theme.colorScheme.onSurface,
      opacity: defaultUnselectedIconTheme?.opacity ?? 1.0,
    );
    final IconThemeData defaultSelectedIconTheme = 
      widget.selectedIconTheme ?? navigationRailTheme.selectedIconTheme;
    final IconThemeData selectedIconTheme = IconThemeData(
      size: defaultSelectedIconTheme?.size ?? 24.0,
      color: defaultSelectedIconTheme?.color ?? theme.colorScheme.primary,
      opacity: defaultSelectedIconTheme?.opacity ?? 0.64,
    );
    final TextStyle unselectedLabelTextStyle = 
      theme.textTheme.bodyText1.copyWith(color: baseColor).merge(
        widget.unselectedLabelTextStyle ?? navigationRailTheme.unselectedLabelTextStyle
      );
    final TextStyle selectedLabelTextStyle = 
      theme.textTheme.bodyText1.copyWith(color: baseSelectedColor).merge(
        widget.selectedLabelTextStyle ?? navigationRailTheme.selectedLabelTextStyle
      );
    final double groupAlignment = 
      widget.groupAlignment ?? navigationRailTheme.groupAlignment ?? -1.0;
    final NavigationRailLabelType labelType = 
      widget.labelType ?? navigationRailTheme.labelType ?? NavigationRailLabelType.none;

    return _ExtendedNavigationRailAnimation(
      animation: _extendedAnimation,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Semantics(
            explicitChildNodes: true,
            child: Material(
              elevation: elevation,
              color: backgroundColor,
              child: Column(
                children: <Widget>[
                  widget.verticalSpacer,
                  if (widget.leading != null)
                    ...<Widget>[
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: lerpDouble(minWidth, minExtendedWidth, _extendedAnimation.value),
                        ),
                        child: widget.leading,
                      ),
                      widget.verticalSpacer,
                    ],
                  Expanded(
                    child: Align(
                      alignment: Alignment(0, groupAlignment),
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: double.minPositive, // viewportConstraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              for (int i = 0; i < widget.destinations.length; i += 1)
                                _RailDestination(
                                  minWidth: minWidth,
                                  minExtendedWidth: minExtendedWidth,
                                  extendedTransitionAnimation: _extendedAnimation,
                                  selected: widget.selectedIndex == i,
                                  icon: widget.selectedIndex == i ? widget.destinations[i].selectedIcon : widget.destinations[i].icon,
                                  label: widget.destinations[i].label,
                                  destinationAnimation: _destinationAnimations[i],
                                  labelType: labelType,
                                  iconTheme: widget.selectedIndex == i ? selectedIconTheme : unselectedIconTheme,
                                  labelTextStyle: widget.selectedIndex == i ? selectedLabelTextStyle : unselectedLabelTextStyle,
                                  onTap: () {
                                    widget.onDestinationSelected(i);
                                  },
                                  indexLabel: localizations.tabLabel(
                                    tabIndex: i + 1,
                                    tabCount: widget.destinations.length,
                                  ),
                                  horizontalDestinationPadding: widget.horizontalDestinationPadding,
                                  verticalDestinationPaddingNoLabel: widget.verticalDestinationPaddingNoLabel,
                                  verticalDestinationPaddingWithLabel: widget.verticalDestinationPaddingWithLabel,
                                  verticalSpacer: widget.verticalSpacer,
                                  roundedHighlight: widget.roundedHighlight,
                                ),
                              if (widget.trailing != null)
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: lerpDouble(minWidth, minExtendedWidth, _extendedAnimation.value),
                                  ),
                                  child: widget.trailing,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _disposeControllers() {
    for (final AnimationController controller in _destinationControllers) {
      controller.dispose();
    }
    _extendedController.dispose();
  }

  void _initControllers() {
    _destinationControllers = List<AnimationController>.generate(widget.destinations.length, (int index) {
      return AnimationController(
        duration: kThemeAnimationDuration,
        vsync: this,
      )..addListener(_rebuild);
    });
    _destinationAnimations = 
      _destinationControllers.map((AnimationController controller) => controller.view).toList();
    _destinationControllers[widget.selectedIndex].value = 1.0;
    _extendedController = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
      value: widget.extended ? 1.0 : 0.0,
    );
    _extendedAnimation = CurvedAnimation(
      parent: _extendedController,
      curve: Curves.easeInOut,
    );
    _extendedController.addListener(() {
      _rebuild();
    });
  }

  void _resetState() {
    _disposeControllers();
    _initControllers();
  }

  void _rebuild() {
    setState(() {
      // Rebuilding when any of the controllers tick, i.e. when the items are
      // animating.
    });
  }
}

class _RailDestination extends StatelessWidget {
  _RailDestination({
    @required this.minWidth,
    @required this.minExtendedWidth,
    @required this.icon,
    @required this.label,
    @required this.destinationAnimation,
    @required this.extendedTransitionAnimation,
    @required this.labelType,
    @required this.selected,
    @required this.iconTheme,
    @required this.labelTextStyle,
    @required this.onTap,
    @required this.indexLabel,
    @required this.horizontalDestinationPadding,
    @required this.verticalDestinationPaddingNoLabel,
    @required this.verticalDestinationPaddingWithLabel,
    @required this.verticalSpacer,
    @required this.roundedHighlight,
  }) : assert(minWidth != null),
       assert(minExtendedWidth != null),
       assert(icon != null),
       assert(label != null),
       assert(destinationAnimation != null),
       assert(extendedTransitionAnimation != null),
       assert(labelType != null),
       assert(selected != null),
       assert(iconTheme != null),
       assert(labelTextStyle != null),
       assert(onTap != null),
       assert(indexLabel != null),
       assert(horizontalDestinationPadding != null),
       assert(verticalDestinationPaddingNoLabel != null),
       assert(verticalDestinationPaddingNoLabel != null),
       assert(verticalSpacer != null),
       _positionAnimation = CurvedAnimation(
          parent: ReverseAnimation(destinationAnimation),
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut.flipped,
       );

  final double minWidth;
  final double minExtendedWidth;
  final Widget icon;
  final Widget label;
  final Animation<double> destinationAnimation;
  final NavigationRailLabelType labelType;
  final bool selected;
  final Animation<double> extendedTransitionAnimation;
  final IconThemeData iconTheme;
  final TextStyle labelTextStyle;
  final VoidCallback onTap;
  final String indexLabel;
  final double horizontalDestinationPadding;
  final double verticalDestinationPaddingNoLabel;
  final double verticalDestinationPaddingWithLabel;
  final Widget verticalSpacer;
  final bool roundedHighlight;
  final Animation<double> _positionAnimation;

  @override
  Widget build(BuildContext context) {
    SizedBox _horizontalDestinationPaddingSizedBox = SizedBox(width: horizontalDestinationPadding);
    EdgeInsets _horizontalDestinationPaddingEdgeInsets = EdgeInsets.symmetric(horizontal: horizontalDestinationPadding);
    
    final Widget themedIcon = IconTheme(
      data: iconTheme,
      child: icon,
    );
    
    final Widget styledLabel = DefaultTextStyle(
      style: labelTextStyle,
      child: label,
    );
    
    Widget content;
    
    switch (labelType) {
      case NavigationRailLabelType.none:
        final Widget iconPart = SizedBox(
          width: minWidth,
          height: minWidth,
          child: Align(
            alignment: Alignment.center,
            child: themedIcon,
          ),
        );
        if (extendedTransitionAnimation.value == 0) {
          content = Stack(
            children: <Widget>[
              iconPart,
              // For semantics when label is not showing,
              SizedBox(
                width: 0,
                height: 0,
                child: Opacity(
                  alwaysIncludeSemantics: true,
                  opacity: 0.0,
                  child: label,
                ),
              ),
            ]
          );
        } else {
          content = ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: lerpDouble(minWidth, minExtendedWidth, extendedTransitionAnimation.value),
            ),
            child: ClipRect(
              child: Row(
                children: <Widget>[
                  iconPart,
                  Align(
                    heightFactor: 1.0,
                    widthFactor: extendedTransitionAnimation.value,
                    alignment: AlignmentDirectional.centerStart,
                    child: Opacity(
                      alwaysIncludeSemantics: true,
                      opacity: _extendedLabelFadeValue(),
                      child: styledLabel,
                    ),
                  ),
                  _horizontalDestinationPaddingSizedBox,
                ],
              ),
            ),
          );
        }
        break;
      case NavigationRailLabelType.selected:
        final double appearingAnimationValue = 1 - _positionAnimation.value;
        final double verticalPadding = 
          lerpDouble(verticalDestinationPaddingNoLabel, verticalDestinationPaddingWithLabel, appearingAnimationValue);
        content = Container(
          constraints: BoxConstraints(
            minWidth: minWidth,
            minHeight: minWidth,
          ),
          padding: _horizontalDestinationPaddingEdgeInsets,
          child: ClipRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: verticalPadding),
                themedIcon,
                Align(
                  alignment: Alignment.topCenter,
                  heightFactor: appearingAnimationValue,
                  widthFactor: 1.0,
                  child: Opacity(
                    alwaysIncludeSemantics: true,
                    opacity: selected ? _normalLabelFadeInValue() : _normalLabelFadeOutValue(),
                    child: styledLabel,
                  ),
                ),
                SizedBox(height: verticalPadding),
              ],
            ),
          ),
        );
        break;
      case NavigationRailLabelType.all:
        content = Container(
          constraints: BoxConstraints(
            minWidth: minWidth,
            minHeight: minWidth,
          ),
          padding: _horizontalDestinationPaddingEdgeInsets,
          child: Column(
            children: <Widget>[
              _horizontalDestinationPaddingSizedBox,
              themedIcon,
              styledLabel,
              _horizontalDestinationPaddingSizedBox,
            ],
          ),
        );
        break;
    }

    final ColorScheme colors = Theme.of(context).colorScheme;
    
    return Semantics(
      container: true,
      selected: selected,
      child: Stack(
        children: <Widget>[
          Material(
            type: MaterialType.transparency,
            clipBehavior: Clip.none,
            child: InkResponse(
              onTap: onTap,
              onHover: (_) {},
              highlightShape: BoxShape.rectangle,
              // borderRadius: BorderRadius.all(Radius.circular(minWidth / 2.0)),
              borderRadius: roundedHighlight 
                  ? BorderRadius.all(Radius.circular(minWidth / 2.0))
                  : BorderRadius.zero,
              containedInkWell: false,
              splashColor: colors.primary.withOpacity(0.12),
              hoverColor: colors.primary.withOpacity(0.04),
              child: content,
            ),
          ),
          Semantics(
            label: indexLabel,
          ),
        ]
      ),
    );
  }

  double _normalLabelFadeInValue() {
    if (destinationAnimation.value < 0.25) {
      return 0;
    } else if (destinationAnimation.value < 0.75) {
      return (destinationAnimation.value - 0.25) * 2;
    } else {
      return 1;
    }
  }

  double _normalLabelFadeOutValue() {
    if (destinationAnimation.value > 0.75) {
      return (destinationAnimation.value - 0.75) * 4.0;
    } else {
      return 0;
    }
  }

  double _extendedLabelFadeValue() {
    return extendedTransitionAnimation.value < 0.25 ? extendedTransitionAnimation.value * 4.0 : 1.0;
  }
}

class _ExtendedNavigationRailAnimation extends InheritedWidget {
  const _ExtendedNavigationRailAnimation({
    Key key,
    @required this.animation,
    @required Widget child,
  }) : assert(child != null),
       super(key: key, child: child);

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_ExtendedNavigationRailAnimation old) => animation != old.animation;
}

const double _minRailWidth = 72.0;
const double _minExtendedRailWidth = 256.0;
