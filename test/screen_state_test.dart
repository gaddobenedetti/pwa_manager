import 'package:flutter_test/flutter_test.dart';

import 'package:pwa_manager/src/screen_state.dart';

void main() {
  group('resolveScreenState', () {
    test('returns unknown off web', () {
      expect(
        resolveScreenState(
          isWeb: false,
          hidden: false,
          focused: true,
          userState: 'active',
          screenState: 'unlocked',
        ),
        PwaScreenState.unknown,
      );
    });

    test('returns active when visible and focused', () {
      expect(
        resolveScreenState(isWeb: true, hidden: false, focused: true),
        PwaScreenState.active,
      );
    });

    test('returns inactive when visible but not focused', () {
      expect(
        resolveScreenState(isWeb: true, hidden: false, focused: false),
        PwaScreenState.inactive,
      );
    });

    test('returns hidden when the document is hidden', () {
      expect(
        resolveScreenState(isWeb: true, hidden: true, focused: false),
        PwaScreenState.hidden,
      );
    });

    test('returns idle when the user is idle and the page is visible', () {
      expect(
        resolveScreenState(
          isWeb: true,
          hidden: false,
          focused: true,
          userState: 'idle',
          screenState: 'unlocked',
        ),
        PwaScreenState.idle,
      );
    });

    test('returns locked when the screen is locked', () {
      expect(
        resolveScreenState(
          isWeb: true,
          hidden: true,
          focused: false,
          userState: 'idle',
          screenState: 'locked',
        ),
        PwaScreenState.locked,
      );
    });

    test('hidden takes priority over idle', () {
      expect(
        resolveScreenState(
          isWeb: true,
          hidden: true,
          focused: false,
          userState: 'idle',
          screenState: 'unlocked',
        ),
        PwaScreenState.hidden,
      );
    });
  });

  group('PwaScreenState', () {
    test('exposes the expected values', () {
      expect(PwaScreenState.values, const [
        PwaScreenState.active,
        PwaScreenState.inactive,
        PwaScreenState.hidden,
        PwaScreenState.idle,
        PwaScreenState.locked,
        PwaScreenState.unknown,
      ]);
    });
  });
}
