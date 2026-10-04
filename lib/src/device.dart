import 'package:flutter/foundation.dart';

/// A detected platform/browser, with the PWA rules used to recognise it from a
/// user-agent string.
enum Device {
  /// Any Android device (not WebView, not Chrome).
  android(true, ['android'], [], ['chrome']),

  /// Android running Chrome: fully PWA-capable.
  androidChrome(true, ['android', 'chrome'], [], []),

  /// Android inside an embedded WebView.
  androidWebView(true, ['android'], ['; wv', ';wv'], []),

  /// iOS Safari version 26 or newer: supports the install prompt.
  iosSafari26OrNewer(true, ['safari'], ['iphone', 'ipad', 'ipod'], ['chrome']),

  /// Older iOS Safari: only supports manual "Add to Home Screen".
  iosSafari(true, ['safari'], ['iphone', 'ipad', 'ipod'], ['chrome']),

  /// Any iOS device (not Safari).
  ios(true, [], ['iphone', 'ipad', 'ipod'], []),

  /// Desktop OS; not PWA-capable in this package.
  desktop(false, null, null, null),

  /// Anything else (e.g. a bot); not PWA-capable.
  unknown(false, null, null, null);

  /// Whether this platform/browser supports installing the PWA.
  final bool supportsPwa;

  /// Tokens that must all appear in the user agent.
  final List<String>? all;

  /// Tokens of which at least one must appear in the user agent.
  final List<String>? any;

  /// Tokens that must not appear in the user agent.
  final List<String>? none;

  const Device(this.supportsPwa, this.all, this.any, this.none);

  /// Whether this is any flavour of iOS Safari (old or 26+).
  bool get isIosSafari => this == iosSafari || this == iosSafari26OrNewer;

  /// Whether the current Flutter target is a desktop operating system.
  static bool get isDesktop => !kIsWeb && (isWindows || isMacOS || isLinux);

  /// Whether the app runs on native Windows.
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  /// Whether the app runs on native Linux.
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  /// Whether the app runs on native macOS.
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  /// Classifies a browser from its [userAgent] string against the enum's
  /// matching rules, verifying the iOS Safari 26+ version, and returns the
  /// matching [Device] (or [Device.unknown]).
  static Device detectDevice(String userAgent) {
    final String ua = userAgent.toLowerCase();
    for (Device device in values) {
      if (device.all == null || device.any == null || device.none == null) {
        return isDesktop ? desktop : unknown;
      }
      bool matchAll = true;
      for (String required in device.all!) {
        if (!ua.contains(required.toLowerCase())) {
          matchAll = false;
        }
      }
      bool matchAny = device.any!.isEmpty;
      for (String optional in device.any!) {
        if (ua.contains(optional.toLowerCase())) {
          matchAny = true;
        }
      }
      bool matchNone = true;
      for (String excluded in device.none!) {
        if (ua.contains(excluded.toLowerCase())) {
          matchNone = false;
        }
      }
      if (matchAll && matchAny && matchNone) {
        if (device == iosSafari26OrNewer) {
          final match = RegExp(r'version/(\d+)\.(\d+)').firstMatch(ua);
          if (match != null && match.groupCount >= 2) {
            final String major = match.group(1) ?? '0';
            final String minor = match.group(2) ?? '0';
            final double version = double.parse('$major.$minor');
            if (version >= 26) {
              return device;
            }
          }
        } else {
          return device;
        }
      }
    }
    return unknown;
  }
}