import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/presenters.dart';

class TestPresenter extends Presenter {}

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(data: MediaQueryData(), child: MaterialApp(home: widget));
}

void main() {
  group('PresenterBuilder', () {
    group('Reactivity Tests', () {
      testWidgets(
          'When constructed with nonReactive shouldn\'t rebuild when notifyListeners is called',
          (WidgetTester tester) async {
        int buildCounter = 0;
        var testPresenter = TestPresenter();
        var widget =
            buildTestableWidget(PresenterBuilder<TestPresenter>.nonReactive(
                builder: (context, model, child) {
                  buildCounter++;
                  return Scaffold();
                },
                presenterBuilder: () => testPresenter));

        await tester.pumpWidget(widget);
        testPresenter.notifyListeners();
        await tester.pumpWidget(widget);
        testPresenter.notifyListeners();
        await tester.pumpWidget(widget);
        testPresenter.notifyListeners();
        await tester.pumpWidget(widget);
        testPresenter.notifyListeners();
        await tester.pumpWidget(widget);
        testPresenter.notifyListeners();
        await tester.pumpWidget(widget);
        testPresenter.notifyListeners();
        await tester.pumpWidget(widget);

        expect(buildCounter, 1);
      });

      testWidgets(
          'When constructed with reactive rebuild when notifyListeners is called',
          (WidgetTester tester) async {
        int buildCounter = 0;
        var testPresenter = TestPresenter();
        var widget =
            buildTestableWidget(PresenterBuilder<TestPresenter>.reactive(
                builder: (context, model, child) {
                  buildCounter++;
                  return Scaffold();
                },
                presenterBuilder: () => testPresenter));

        await tester.pumpWidget(widget);
        testPresenter.notifyListeners();
        await tester.pumpWidget(widget);
        testPresenter.notifyListeners();
        await tester.pumpWidget(widget);
        testPresenter.notifyListeners();
        await tester.pumpWidget(widget);

        expect(buildCounter, 4);
      });

      testWidgets(
          'When constructed after dispose, should trigger presenter builder again',
          (WidgetTester tester) async {
        final stateKey = GlobalKey<State<PresenterBuilder<TestPresenter>>>();
        int buildCounter = 0;
        var testPresenter = TestPresenter();
        var widget = PresenterBuilder<TestPresenter>.reactive(
          builder: (context, model, child) {
            return Container();
          },
          presenterBuilder: () {
            buildCounter++;
            return testPresenter;
          },
          key: stateKey,
        );

        await tester.pumpWidget(widget);

        stateKey.currentState.dispose();
        await tester.pumpWidget(widget);

        stateKey.currentState.reassemble();
        await tester.pumpWidget(widget);

        stateKey.currentState.initState();
        await tester.pumpWidget(widget);

        expect(buildCounter, 2);
      }, skip: true);
    });
  });
}
