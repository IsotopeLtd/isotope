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
          'When constructed with nonReactive shouldn\'t rebuild when notifyListerens is called',
          (WidgetTester tester) async {
        int buildCounter = 0;
        var testPresenter = TestPresenter();
        await tester.pumpWidget(
            buildTestableWidget(PresenterBuilder<TestPresenter>.nonReactive(
                builder: (context, model, child) {
                  buildCounter++;
                  return Scaffold();
                },
                presenterBuilder: () => testPresenter
              )
            )
        );

        testPresenter.notifyListeners();
        testPresenter.notifyListeners();
        testPresenter.notifyListeners();
        testPresenter.notifyListeners();
        testPresenter.notifyListeners();
        testPresenter.notifyListeners();

        expect(buildCounter, 1);
      });
    });
  });
}
