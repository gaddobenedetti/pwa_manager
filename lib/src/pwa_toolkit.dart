import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'update_check.dart';

/// JS interop for accessing the early-captured beforeinstallprompt event.
/// This is set by a script in index.html before Flutter loads.
@JS('__pwaInstallPrompt')
external JSAny? get _earlyPwaInstallPrompt;

/// Extension type for BeforeInstallPromptEvent which adds the prompt() method.
/// This event is not in the web package, so we define our own interop.
extension type _BeforeInstallPromptEvent._(JSObject _) implements web.Event {
  /// Calls the native `prompt()` method on the install prompt event.
  external void prompt();
}

/// Singleton owning the browser interop: the deferred install prompt, the
/// lifecycle event listeners and the version/update machinery.
class PwaToolkit {
  /// The shared singleton instance.
  static final PwaToolkit _instance = PwaToolkit._internal();

  /// Prefix used to namespace localStorage keys per app path.
  String _storagePrefix = '';

  /// Returns the shared singleton instance.
  factory PwaToolkit() {
    return _instance;
  }

  /// Event fired before the install prompt is shown.
  web.Event? _deferredPrompt;

  /// Notifies when the install prompt is ready to be shown.
  final ValueNotifier<bool> installPromptEnabled = ValueNotifier(false);

  /// Notifies when the PWA has been successfully installed.
  final ValueNotifier<bool> isInstalled = ValueNotifier(false);

  /// localStorage key under which the last seen server version is stored.
  static const versionKey = "_version";

  /// Whether the event listeners have already been registered.
  bool _initialized = false;

  /// Creates the singleton, derives the storage prefix and registers the
  /// browser event listeners.
  PwaToolkit._internal() {
    _storagePrefix = _derivePrefix();
    _init();
  }

  /* ************************************************************************ */

  /// Static wrapper for [PwaToolkit._init].
  static void init() => _instance._init();

  /// Static wrapper for [PwaToolkit._promptInstall].
  static Future<void> promptInstall() => _instance._promptInstall();

  /// Static wrapper for [PwaToolkit._getWebAddress].
  static String getWebAddress() => _instance._getWebAddress();

  /// Static wrapper for [PwaToolkit._updatePwa].
  static Future<void> updatePwa() => _instance._updatePwa();

  /// Static wrapper for [PwaToolkit._checkForUpdate].
  static Future<void> checkForUpdate(
    UpdateCriteria criteria,
    VoidCallback onUpdate,
  ) => _instance._checkForUpdate(criteria, onUpdate);

  /* ************************************************************************ */

  /// Registers the `beforeinstallprompt`/`appinstalled` listeners and recovers
  /// a prompt that was captured before Flutter loaded.
  void _init() {
    if (_initialized) return;
    _initialized = true;

    web.window.addEventListener(
      'beforeinstallprompt',
      (web.Event event) {
        _deferredPrompt = event;
        installPromptEnabled.value = true;
        debugPrint('beforeinstallprompt event fired');
      }.toJS,
    );

    web.window.addEventListener(
      'appinstalled',
      (web.Event event) {
        _deferredPrompt = null;
        installPromptEnabled.value = false;
        isInstalled.value = true;
        // TODO: Inform user app is installed.
        debugPrint('PWA was installed');
      }.toJS,
    );

    final earlyPrompt = _earlyPwaInstallPrompt;
    if (earlyPrompt != null) {
      _deferredPrompt = _BeforeInstallPromptEvent._(earlyPrompt as JSObject);
      installPromptEnabled.value = true;
      debugPrint('beforeinstallprompt: recovered from pre-Flutter capture');
    }
  }

  /// Shows the browser's native install prompt and clears the deferred event.
  Future<void> _promptInstall() async {
    final prompt = _deferredPrompt;
    if (prompt != null) {
      // Show the install prompt using typed js_interop
      (_BeforeInstallPromptEvent._(prompt as JSObject)).prompt();

      // Clear the prompt after use
      _deferredPrompt = null;
      installPromptEnabled.value = false;
    }
  }

  /// Returns the current page URL.
  String _getWebAddress() => web.window.location.href;

  /// Fetches the latest server version, stores it locally and reloads the page.
  Future<void> _updatePwa() async {
    String? serverVersion = await _getServerVersion();
    if (serverVersion != null) {
      _setLocalStorage(versionKey, serverVersion);
      web.window.location.reload();
    }
  }

  /// Derives a per-app storage key prefix from the URL path (last non-empty
  /// segment), falling back to the hostname.
  static String _derivePrefix() {
    String path = web.window.location.pathname;
    path = path.replaceAll(RegExp(r'/$'), '');
    if (path.endsWith('index.html')) {
      path = path.substring(0, path.length - 'index.html'.length);
      path = path.replaceAll(RegExp(r'/$'), '');
    }
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return web.window.location.hostname;
    return segments.last;
  }

  /// Compares the server version against the stored one and calls [onUpdate]
  /// when [criteria] decides an update should be offered.
  Future<void> _checkForUpdate(
    UpdateCriteria criteria,
    VoidCallback onUpdate,
  ) async {
    try {
      final serverVersion = await _getServerVersion();
      if (serverVersion == null) return;

      final storedVersion = _getLocalStorage(versionKey);

      if (storedVersion == null) {
        _setLocalStorage(versionKey, serverVersion);
        return;
      }

      if (!shouldUpdate(criteria, serverVersion, storedVersion)) {
        return;
      }

      onUpdate();
    } catch (_) {}
  }

  /// Fetches and parses `version.json` next to the current page and returns its
  /// `version` field (null on any failure).
  Future<String?> _getServerVersion() async {
    final url = Uri.parse(
      web.window.location.href,
    ).resolve('version.json').toString();
    final response = await web.window.fetch(url.toJS).toDart;
    final body = await response.text().toDart;
    final text = body.toDart;
    final json = jsonDecode(text) as Map<String, dynamic>;
    return json['version'] as String?;
  }

  /// Reads a prefixed value from localStorage.
  String? _getLocalStorage(String key) =>
      web.window.localStorage.getItem('$_storagePrefix$key');

  /// Writes a prefixed value to localStorage.
  void _setLocalStorage(String key, String value) =>
      web.window.localStorage.setItem('$_storagePrefix$key', value);
}