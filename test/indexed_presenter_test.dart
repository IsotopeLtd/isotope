import 'package:flutter_test/flutter_test.dart';
import 'package:isotope/presenters.dart';

void main() {
  group('IndexedPresenterTest -', () {
    group('setIndex -', () {
      test('When called with 1, should set currentIndex to 1', () {
        var model = IndexedPresenter();
        model.setIndex(1);
        expect(model.currentIndex, 1);
      });

      test('When called with 1, should notifyListeners about update', () {
        var model = IndexedPresenter();
        var called = false;

        model.addListener(() {
          called = true;
        });

        model.setIndex(1);
        expect(called, true);
      });

      test(
          'When called with 1 and currentIndex was 0, reverse should return false',
          () {
        var model = IndexedPresenter();
        model.setIndex(1);
        expect(model.reverse, false);
      });

      test(
          'When called with 0 and currentIndex was 1, reverse should return true',
          () {
        var model = IndexedPresenter();
        model.setIndex(1);
        model.setIndex(0);
        expect(model.reverse, true);
      });

      test('When called with 1 isIndexSelected should return false for 0', () {
        var model = IndexedPresenter();
        model.setIndex(1);
        expect(model.isIndexSelected(0), false);
      });

      test('When called with 1 isIndexSelected should return true for 1', () {
        var model = IndexedPresenter();
        model.setIndex(1);
        expect(model.isIndexSelected(1), true);
      });
    });
  });
}
