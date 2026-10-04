import 'package:flutter_test/flutter_test.dart';

import 'package:pwa_manager/src/update_check.dart';

void main() {
  group('parseVersion', () {
    test('parses a 0.0.0 version', () {
      expect(parseVersion('1.2.3'), [1, 2, 3]);
    });

    test('ignores non-numeric characters', () {
      expect(parseVersion('v1.2.3'), [1, 2, 3]);
      expect(parseVersion('1.2.3-beta'), [1, 2, 3]);
    });

    test('rejects malformed versions', () {
      expect(parseVersion('1.2'), isNull);
      expect(parseVersion('1.2.3.4'), isNull);
      expect(parseVersion('abc'), isNull);
      expect(parseVersion(''), isNull);
    });
  });

  group('shouldUpdate', () {
    test('anyUpgrade triggers only on upgrades', () {
      expect(shouldUpdate(UpdateCriteria.anyUpgrade, '1.2.3', '1.2.2'), isTrue);
      expect(shouldUpdate(UpdateCriteria.anyUpgrade, '1.3.0', '1.2.9'), isTrue);
      expect(shouldUpdate(UpdateCriteria.anyUpgrade, '2.0.0', '1.9.9'), isTrue);
      expect(shouldUpdate(UpdateCriteria.anyUpgrade, '1.2.2', '1.2.3'), isFalse);
    });

    test('majorUpgrade triggers only on major bumps', () {
      expect(shouldUpdate(UpdateCriteria.majorUpgrade, '2.0.0', '1.9.9'), isTrue);
      expect(shouldUpdate(UpdateCriteria.majorUpgrade, '1.3.0', '1.2.0'), isFalse);
    });

    test('minorUpgrade triggers on major or minor bumps', () {
      expect(shouldUpdate(UpdateCriteria.minorUpgrade, '1.3.0', '1.2.0'), isTrue);
      expect(shouldUpdate(UpdateCriteria.minorUpgrade, '1.2.3', '1.2.0'), isFalse);
    });

    test('any triggers on any difference including downgrades', () {
      expect(shouldUpdate(UpdateCriteria.any, '1.2.3', '1.2.3'), isFalse);
      expect(shouldUpdate(UpdateCriteria.any, '2.0.0', '1.0.0'), isTrue);
      expect(shouldUpdate(UpdateCriteria.any, '1.0.0', '2.0.0'), isTrue);
    });

    test('noUpdateCheck never triggers', () {
      expect(shouldUpdate(UpdateCriteria.noUpdateCheck, '2.0.0', '1.0.0'), isFalse);
    });
  });
}