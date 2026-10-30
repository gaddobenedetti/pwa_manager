/// The visibility/activity state of the app, as far as the browser can report.
///
/// Cross-browser support is limited:
///
/// * [active], [inactive] and [hidden] are available in every modern browser.
/// * [idle] and [locked] require the Chromium-only Idle Detection API and are
///   reported only while it is running.
/// * [unknown] is returned off web, or before the browser signals are read.
///
/// A screen being off or locked surfaces as [hidden] on mobile browsers, but
/// cannot be distinguished from a backgrounded tab without the Idle Detection
/// API. On desktop, display sleep is often not reported at all.
enum PwaScreenState {
  /// The page is visible and the window has focus.
  active,

  /// The page is visible but the window does not have focus.
  inactive,

  /// The page is not visible: the tab was switched, the window minimized, the
  /// app backgrounded, or (on mobile) the screen turned off or locked.
  hidden,

  /// The user has not interacted with the device for the configured threshold.
  ///
  /// Only reported while idle detection is running on a browser that supports
  /// it.
  idle,

  /// The device screen is locked.
  ///
  /// Only reported while idle detection is running on a browser that supports
  /// it.
  locked,

  /// The state cannot be determined (off web, or no signal received yet).
  unknown,
}

/// Resolves a [PwaScreenState] from the raw browser signals.
///
/// Priority is `locked > hidden > idle > inactive > active`; off web the state
/// is always [PwaScreenState.unknown].
PwaScreenState resolveScreenState({
  required bool isWeb,
  required bool hidden,
  required bool focused,
  String? userState,
  String? screenState,
}) {
  if (!isWeb) return PwaScreenState.unknown;
  if (screenState == 'locked') return PwaScreenState.locked;
  if (hidden) return PwaScreenState.hidden;
  if (userState == 'idle') return PwaScreenState.idle;
  return focused ? PwaScreenState.active : PwaScreenState.inactive;
}
