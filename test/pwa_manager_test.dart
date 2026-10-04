import 'package:flutter_test/flutter_test.dart';

import 'package:pwa_manager/src/device.dart';

const String desktopChromeUa =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

const String androidChromeUa =
    'Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';

const String iosSafariUa =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) '
    'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 '
    'Mobile/15E148 Safari/604.1';

const String iosSafari26Ua =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) '
    'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 '
    'Mobile/15E148 Safari/604.1';

void main() {
  group('Device', () {
    test('enum pwa flags are correct', () {
      expect(Device.androidChrome.supportsPwa, isTrue);
      expect(Device.android.supportsPwa, isTrue);
      expect(Device.iosSafari.supportsPwa, isTrue);
      expect(Device.iosSafari26OrNewer.supportsPwa, isTrue);
      expect(Device.ios.supportsPwa, isTrue);
      expect(Device.desktop.supportsPwa, isFalse);
      expect(Device.unknown.supportsPwa, isFalse);
    });

    test('detects Android Chrome', () {
      expect(Device.detectDevice(androidChromeUa), Device.androidChrome);
    });

    test('detects iOS Safari', () {
      expect(Device.detectDevice(iosSafariUa), Device.iosSafari);
    });

    test('detects iOS Safari 26+', () {
      expect(Device.detectDevice(iosSafari26Ua), Device.iosSafari26OrNewer);
    });

    test('desktop user agents are not PWA capable', () {
      expect(Device.detectDevice(desktopChromeUa).supportsPwa, isFalse);
    });

    test('isIosSafari includes both Safari variants', () {
      expect(Device.iosSafari.isIosSafari, isTrue);
      expect(Device.iosSafari26OrNewer.isIosSafari, isTrue);
      expect(Device.androidChrome.isIosSafari, isFalse);
      expect(Device.desktop.isIosSafari, isFalse);
    });
  });
}
