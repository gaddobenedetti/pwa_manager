import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'device.dart';

/// Web-only helpers exposing the browser's user agent, the detected [Device]
/// and the current PWA install state.
class DeviceWeb {
  /// The browser's user-agent string, lowercased (empty off web).
  static String get userAgent {
    if (!kIsWeb) return '';
    return web.window.navigator.userAgent.toLowerCase();
  }

  /// The [Device] detected from the current browser, or [Device.unknown] off
  /// web.
  static Device get device {
    if (!kIsWeb) return Device.unknown;
    return Device.detectDevice(userAgent);
  }

  /// Whether the current browser is iOS Safari (any version).
  static bool get isIosSafari => device.isIosSafari;

  /// Whether the current browser is Android Chrome.
  static bool get isAndroidChrome => device == Device.androidChrome;

  /// Whether the PWA is already installed, checked via the standalone/fullscreen
  /// display mode or the iOS-specific `navigator.standalone` flag.
  static bool isPwaInstalled() {
    if (!kIsWeb) return false;

    try {
      if (web.window.matchMedia('(display-mode: standalone)').matches ||
          web.window.matchMedia('(display-mode: fullscreen)').matches) {
        return true;
      }

      if (isIosSafari) {
        final standaloneValue = (web.window.navigator as dynamic).standalone;
        return standaloneValue == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}