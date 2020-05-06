# Views

A responsive builder package containing widgets that allows you to create a readable responsive UI.

It aims to provide you with widgets that make it easy to build different UI's along two different Axis. Orientation x ScreenType. This means you can have a separate layout for Mobile - Landscape, Mobile - Portrait, Tablet - Landscape and Tablet-Portrait.

## Installation

Add `isotope` as a dependency in your `pubspec.yaml` file.

```
responsive:
  git: git://github.com/isotopestudio/isotope.git
```

## Usage

Import the `isotope/views.dart` library:

```dart
import 'package:isotope/views.dart';
```

### Responsive Builder

This package provides a widget called `ResponsiveBuilder` that provides you with a builder function that returns the current `ScreenInfo`. The `screenInfo` includes the `responsiveDevice`, `screenSize` and `widgetSize`. This can be used for fine grained responsive control from a view level down to per widget responsive level.

The `ResponsiveBuilder` is used as any other builder widget.

```dart
// import the package
import 'package:responsive/responsive.dart';

// Use the widget
ResponsiveBuilder(
  builder: (context, screenInfo) {
    // Check the sizing information here and return your UI
    if (screenInfo.responsiveDevice == ResponsiveDevice.Desktop) {
      return Container(color:Colors.blue);
    }

    if (screenInfo.responsiveDevice == ResponsiveDevice.Tablet) {
      return Container(color:Colors.red);
    }

    if (screenInfo.responsiveDevice == ResponsiveDevice.Watch) {
      return Container(color:Colors.yellow);
    }

    return Container(color:Colors.purple);
  },
);
```

This will return different colour containers depending on which device it is being shown on. A simple way to test this is to either run your code on Flutter web and resize the window or add the [device_preview](https://pub.dev/packages/device_preview) package and view on different devices.

## Orientation Layout

This widget can be seen as a duplicate of the `OrientationBuilder` that comes with Flutter, but the point of this library is to help you produce a readable responsive UI codebase.

The usage is easy. Provide a builder function that returns a UI for each of the orientations. 

```dart
// import the package
import 'package:responsive/responsive.dart';

// Return a widget function per orientation
OrientationLayout(
  portrait: (context) => Container(color: Colors.green),
  landscape: (context) => Container(color: Colors.pink),
),
```

This will return a different coloured container when you swap orientations for your device. In a more readable manner than checking the orientation with a conditional.

## Responsive Layout

This widget is similar to the Orientation Layout Builder in that it takes in Widgets that are named and displayed for different screen types. The naming is nto important and you can use your own convention.

```dart
// import the package
import 'package:responsive/responsive.dart';

// Construct and pass in a widget per screen type
ResponsiveLayout(
  mobile: Container(color:Colors.blue)
  tablet: Container(color: Colors.yellow),
  desktop: Container(color: Colors.red),
  watch: Container(color: Colors.purple),
);
```

If you do not want to build all the widgets at once, you can use the widget builder. A widget for the right type of screen will be created only when needed.

```dart
// Construct and pass in a widget builder per screen type
ResponsiveLayout.builder(
  mobile: (BuildContext context) => Container(color:Colors.blue),
  tablet: (BuildContext context) => Container(color:Colors.yellow),
  desktop: (BuildContext context) => Container(color:Colors.red),
  watch: (BuildContext context) => Container(color:Colors.purple),
);
```

## Custom Screen Breakpoints

If you wish to define your own custom break points you can do so by supplying either the `ResponsiveLayout` or `ResponsiveBuilder` widgets with a `breakpoints` argument.

``` dart
// import the package
import 'package:responsive/responsive.dart';

// ResponsiveLayout with custom breakpoints supplied
ResponsiveLayout(
  breakpoints: ResponsiveBreakpoints(
    tablet: 600,
    desktop: 950,
    watch: 300
  ),
  mobile: Container(color:Colors.blue)
  tablet: Container(color: Colors.yellow),
  desktop: Container(color: Colors.red),
  watch: Container(color: Colors.purple),
);
```

## Responsive Helpers

Responsive helpers provide a set of functions that help with responsive sizing and spacing in general.

### Spacing

#### Horizontal Spacers

- `horizontalSpaceTiny` a SizedBox with a width of 5.0
- `horizontalSpaceSmall` a SizedBox with a width of 10.0
- `horizontalSpaceMedium` a SizedBox with a width of 25.0
- `horizontalSpaceLarge` a SizedBox with a width of 50.0

#### Vertical Spacers

- `verticalSpaceTiny` a SizedBox with a height of 5.0
- `verticalSpaceSmall` a SizedBox with a height of 10.0
- `verticalSpaceMedium` a SizedBox with a height of 25.0
- `verticalSpaceLarge` a SizedBox with a height of 50.0
- `verticalSpaceMassive` a SizedBox with a height of 120.0
- `verticalSpace(height)` a sized box with a custom height (double)
- `spacedDivider` a Divider flanked by verticalSpaceMedium
- `responsiveVerticalSpaceSmall`

### Screen Width

- `screenWidth` returns the screen width (double) from a MediaQuery
- `halfScreenWidth(context)` return half screen width (double), requires BuildContext
- `thirdScreenWidth(context)` returns a third screen width (double), requires BuildContext

### Screen Height

- `screenHeight` returns the screen height (double) from a MediaQuery

### Font Sizing

- `getResponsiveSmallFontSize` returns a double
- `getResponsiveMediumFontSize` returns a double
- `getResponsiveLargeFontSize` returns a double
- `getResponsiveExtraLargeFontSize` returns a double
- `getResponsiveMassiveFontSize` returns a double
