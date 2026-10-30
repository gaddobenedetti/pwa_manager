import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'screen_state.dart';

/// Minimal interop for the Idle Detection API, which `package:web` does not
/// expose yet.
@JS('IdleDetector')
extension type _IdleDetector._(JSObject _)
    implements web.EventTarget, JSObject {
  /// Creates a new idle detector.
  external factory _IdleDetector();

  /// Requests the `idle-detection` permission. Must be called from a user
  /// gesture.
  external static JSPromise<JSString> requestPermission();

  /// Starts watching for idle/screen changes.
  external JSPromise<JSAny?> start(_IdleDetectorOptions options);

  /// `'active'` or `'idle'` once started.
  external String? get userState;

  /// `'locked'` or `'unlocked'` once started.
  external String? get screenState;
}

/// Options passed to [_IdleDetector.start].
extension type _IdleDetectorOptions._(JSObject _) implements JSObject {
  external factory _IdleDetectorOptions({
    int threshold,
    web.AbortSignal signal,
  });
}

/// Web-only helpers exposing the browser's visibility/activity state.
///
/// The baseline (visible/hidden/focused) is built on the Page Visibility and
/// focus APIs, so it works in every modern browser. The [PwaScreenState.idle]
/// and [PwaScreenState.locked] states additionally require the Chromium-only
/// Idle Detection API, and are only available after [startIdleDetection] has
/// been called from a user gesture.
class ScreenStateWeb {
  ScreenStateWeb._();

  static final ScreenStateWeb _instance = ScreenStateWeb._();

  /// Broadcast stream of state changes, created lazily.
  final StreamController<PwaScreenState> _controller =
      StreamController<PwaScreenState>.broadcast();

  /// The last resolved state.
  PwaScreenState _current = PwaScreenState.unknown;

  /// Whether the browser listeners have been registered.
  bool _initialized = false;

  /// Whether the document is hidden.
  bool _hidden = false;

  /// Whether the window currently has focus.
  bool _focused = true;

  /// The last `IdleDetector.userState` reading, if any.
  String? _userState;

  /// The last `IdleDetector.screenState` reading, if any.
  String? _screenState;

  /// Controller used to abort the running idle detector.
  web.AbortController? _abortController;

  /// The active wake lock sentinel, if any.
  web.WakeLockSentinel? _wakeLock;

  /// Whether a screen wake lock is currently held.
  bool _wakeLockActive = false;

  /// The current [PwaScreenState] (or [PwaScreenState.unknown] off web).
  static PwaScreenState get current {
    _instance._ensureInitialized();
    return _instance._current;
  }

  /// Emits a new [PwaScreenState] whenever the browser reports a change.
  static Stream<PwaScreenState> get onChanged {
    _instance._ensureInitialized();
    return _instance._controller.stream;
  }

  /// Whether this browser can report [PwaScreenState.idle] and
  /// [PwaScreenState.locked].
  ///
  /// Requires a Chromium-based browser and a secure context.
  static bool get supportsIdleDetection {
    if (!kIsWeb) return false;
    try {
      return web.window.isSecureContext && web.window.has('IdleDetector');
    } catch (_) {
      return false;
    }
  }

  /// Whether a screen wake lock is currently held.
  static bool get wakeLockActive {
    _instance._ensureInitialized();
    return _instance._wakeLockActive;
  }

  /// Starts idle/screen-lock detection.
  ///
  /// This must be called from a user gesture (for example a button tap) so the
  /// browser can request the `idle-detection` permission. [threshold] is the
  /// inactivity delay in milliseconds and is clamped to the API minimum of
  /// 60000 ms. Returns whether detection started successfully.
  static Future<bool> startIdleDetection({int threshold = 60000}) =>
      _instance._startIdleDetection(threshold);

  /// Stops idle/screen-lock detection and forgets its last readings.
  static void stopIdleDetection() => _instance._stopIdleDetection();

  /// Requests a screen wake lock so the display does not dim or sleep.
  ///
  /// Returns whether the lock was acquired. This is a convenience proxy, not a
  /// screen-state detector: the browser releases the lock when the document
  /// becomes hidden or the device suspends.
  static Future<bool> keepScreenOn() => _instance._keepScreenOn();

  /// Releases any screen wake lock held by [keepScreenOn].
  static Future<void> allowScreenOff() => _instance._allowScreenOff();

  /// Registers the browser listeners once and reads the initial state.
  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    if (!kIsWeb) return;

    _hidden = web.document.hidden;
    _focused = web.document.hasFocus();
    _current = _resolve();

    web.document.addEventListener(
      'visibilitychange',
      ((web.Event _) {
        _hidden = web.document.hidden;
        _emit();
      }).toJS,
    );

    web.window.addEventListener(
      'focus',
      ((web.Event _) {
        _focused = true;
        _emit();
      }).toJS,
    );

    web.window.addEventListener(
      'blur',
      ((web.Event _) {
        _focused = false;
        _emit();
      }).toJS,
    );

    web.document.addEventListener(
      'pagehide',
      ((web.Event _) {
        _hidden = true;
        _emit();
      }).toJS,
    );

    web.document.addEventListener(
      'pageshow',
      ((web.Event _) {
        _hidden = web.document.hidden;
        _emit();
      }).toJS,
    );

    web.document.addEventListener(
      'freeze',
      ((web.Event _) {
        _hidden = true;
        _emit();
      }).toJS,
    );

    web.document.addEventListener(
      'resume',
      ((web.Event _) {
        _hidden = web.document.hidden;
        _emit();
      }).toJS,
    );
  }

  /// Resolves the current state from the cached browser signals.
  PwaScreenState _resolve() => resolveScreenState(
    isWeb: kIsWeb,
    hidden: _hidden,
    focused: _focused,
    userState: _userState,
    screenState: _screenState,
  );

  /// Resolves the current state and notifies listeners when it changed.
  void _emit() {
    final PwaScreenState next = _resolve();
    if (next == _current) return;
    _current = next;
    if (!_controller.isClosed) _controller.add(next);
  }

  /// Starts the Idle Detection API and merges its readings into the stream.
  Future<bool> _startIdleDetection(int threshold) async {
    if (!supportsIdleDetection) return false;

    final int effectiveThreshold = threshold < 60000 ? 60000 : threshold;

    try {
      final JSString permission =
          await _IdleDetector.requestPermission().toDart;
      if (permission.toDart != 'granted') return false;

      _stopIdleDetection();

      final web.AbortController controller = web.AbortController();
      _abortController = controller;

      final _IdleDetector detector = _IdleDetector();
      detector.addEventListener(
        'change',
        ((web.Event _) {
          _userState = detector.userState;
          _screenState = detector.screenState;
          _emit();
        }).toJS,
      );

      await detector
          .start(
            _IdleDetectorOptions(
              threshold: effectiveThreshold,
              signal: controller.signal,
            ),
          )
          .toDart;

      _userState = detector.userState;
      _screenState = detector.screenState;
      _emit();
      return true;
    } catch (_) {
      _abortController = null;
      return false;
    }
  }

  /// Aborts the idle detector and clears its readings.
  void _stopIdleDetection() {
    _abortController?.abort();
    _abortController = null;
    _userState = null;
    _screenState = null;
    _emit();
  }

  /// Acquires a screen wake lock.
  Future<bool> _keepScreenOn() async {
    if (!kIsWeb) return false;
    try {
      if (!web.window.navigator.has('wakeLock')) return false;
      await _wakeLock?.release().toDart;
      final web.WakeLockSentinel sentinel = await web.window.navigator.wakeLock
          .request('screen')
          .toDart;
      _wakeLock = sentinel;
      _wakeLockActive = true;
      sentinel.addEventListener(
        'release',
        ((web.Event _) {
          if (!identical(_wakeLock, sentinel)) return;
          _wakeLock = null;
          _wakeLockActive = false;
        }).toJS,
      );
      return true;
    } catch (_) {
      _wakeLock = null;
      _wakeLockActive = false;
      return false;
    }
  }

  /// Releases the screen wake lock, if any.
  Future<void> _allowScreenOff() async {
    if (!kIsWeb) return;
    try {
      await _wakeLock?.release().toDart;
    } catch (_) {}
    _wakeLock = null;
    _wakeLockActive = false;
  }
}
