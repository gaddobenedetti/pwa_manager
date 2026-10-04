import 'package:flutter/material.dart';
import 'package:pwa_manager/src/device.dart';
import 'package:pwa_manager/src/widget_mobile_prompt.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'pwa_formatting.dart';
import 'src/device_web.dart';
import 'src/pwa_toolkit.dart';
import 'src/update_check.dart';
import 'src/widget_android_install_prompt.dart';
import 'src/widget_desktop_prompt.dart';
import 'src/widget_ios_install_prompt.dart';
import 'src/widget_update_prompt.dart';

export 'src/update_check.dart';

/*
  **Setup:** For the install prompt to be reliably caught on Android Chrome,
  add the following early-capture script to your app's `index.html` before
  the Flutter bootstrap:

  <script>
    window.addEventListener('beforeinstallprompt', (e) => {
      window.__pwaInstallPrompt = e;
    });
  </script>
  ```
*/

/// Top-level widget wrapping your app; shows the correct PWA install/update
/// prompt for the detected platform, or the app's [home] when already
/// installed/disabled.
class PwaManager extends StatefulWidget {
  /// Whether the PWA prompt logic is active at all (when false, [home] is
  /// always shown).
  final bool enabled;

  /// Whether install prompts are only shown on mobile devices.
  final bool requireMobile;

  /// Whether the user is forced to install the app (hides the pass-through
  /// link that normally navigates to [home]).
  final bool requireInstall;

  /// Optional user-supplied widget replacing the default desktop QR prompt.
  final Widget? customWidgetDesktopPrompt;

  /// Optional user-supplied widget replacing the default generic mobile prompt.
  final Widget? customWidgetMobilePrompt;

  /// Optional user-supplied widget replacing the default Android Chrome
  /// install prompt.
  final Widget? customAndroidWidgetInstallPrompt;

  /// Optional user-supplied widget replacing the default iOS Safari install
  /// prompt.
  final Widget? customIosWidgetInstallPrompt;

  /// Optional user-supplied dialog replacing the default update dialog.
  final AlertDialog? customWidgetUpdatePrompt;

  /// Text, colors and logo used by the default prompt widgets.
  final PwaFormatting? pwaData;

  /// Version comparison policy used when checking for updates.
  final UpdateCriteria updateCriteria;

  /// The actual app content shown after the PWA is installed.
  final Widget home;

  const PwaManager({
    super.key,
    this.enabled = true,
    this.requireMobile = false,
    this.requireInstall = false,
    this.customWidgetDesktopPrompt,
    this.customWidgetMobilePrompt,
    this.customAndroidWidgetInstallPrompt,
    this.customIosWidgetInstallPrompt,
    this.customWidgetUpdatePrompt,
    this.pwaData,
    this.updateCriteria = UpdateCriteria.any,
    required this.home,
  });

  /// Registers the browser's install/installed event listeners once.
  static void init() => PwaToolkit.init();

  /// Triggers the browser's native install prompt if one is pending.
  static Future<void> promptInstall() async => PwaToolkit.promptInstall();

  /// Builds a QR code widget pointing at the current web address.
  ///
  /// [size] sets the square dimensions, [customUrl] overrides the encoded
  /// address, [logo] is embedded in the centre, and the remaining arguments
  /// control the QR colours.
  static Widget getDownloadQr({
    required double size,
    String? customUrl,
    Color backgroundColor = Colors.white,
    ImageProvider? logo,
    Color eyeColor = Colors.black,
    Color dataColor = Colors.black,
  }) {
    return QrImageView(
      data: customUrl ?? PwaToolkit.getWebAddress(),
      embeddedImage: logo,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor,
      eyeStyle: QrEyeStyle(color: eyeColor, eyeShape: QrEyeShape.square),
      dataModuleStyle: QrDataModuleStyle(
        color: dataColor,
        dataModuleShape: QrDataModuleShape.square,
      ),
    );
  }

  /// Returns the current web address of the running PWA.
  static String getWebAddress() => PwaToolkit.getWebAddress();

  /// Stores the latest server version and reloads the page to apply updates.
  static void updatePwa() => PwaToolkit.updatePwa();

  @override
  State<PwaManager> createState() => _PwaManagerState();
}

/// State of [PwaManager]; builds and displays the matching prompt widget.
class _PwaManagerState extends State<PwaManager> {
  /// Whether the update check has already been scheduled this session.
  bool _checkedUpdate = false;

  /// Schedules the update check to run after the first frame is painted.
  void _scheduleUpdateCheck() {
    if (_checkedUpdate ||
        widget.updateCriteria == UpdateCriteria.noUpdateCheck) {
      return;
    }
    _checkedUpdate = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      PwaToolkit.checkForUpdate(widget.updateCriteria, _onUpdateAvailable);
    });
  }

  /// Shows the update-available dialog (custom or the default one).
  void _onUpdateAvailable() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          widget.customWidgetUpdatePrompt ??
          WidgetUpdatePrompt(
            pwaData: widget.pwaData ?? PwaFormatting(),
            home: !widget.requireInstall ? widget.home : null,
          ),
    );
  }

  /// Returns the Android Chrome install prompt.
  Widget _getAndroidChrome() =>
      widget.customAndroidWidgetInstallPrompt ??
      WidgetAndroidInstallPrompt(
        pwaData: widget.pwaData ?? PwaFormatting(),
        home: !widget.requireInstall ? widget.home : null,
      );

  /// Returns the iOS Safari install prompt.
  Widget _getSafariIos() =>
      widget.customIosWidgetInstallPrompt ??
      WidgetIosInstallPrompt(
        pwaData: widget.pwaData ?? PwaFormatting(),
        home: !widget.requireInstall ? widget.home : null,
      );

  /// Returns the generic mobile install prompt.
  Widget _getGenericMobile() =>
      widget.customWidgetMobilePrompt ??
      WidgetMobilePrompt(
        pwaData: widget.pwaData ?? PwaFormatting(),
        home: !widget.requireInstall ? widget.home : null,
      );

  /// Returns the desktop/non-PWA prompt.
  Widget _getNonPwaPlatform() =>
      widget.customWidgetDesktopPrompt ??
      WidgetDesktopPrompt(
        pwaData: widget.pwaData ?? PwaFormatting(),
        home: !widget.requireMobile ? widget.home : null,
      );

  /// Routes the wrapped app to the prompt matching the detected device, or to
  /// [PwaManager.home] when the PWA is installed or prompting is disabled.
  @override
  Widget build(BuildContext context) {
    if (widget.enabled) {
      if (DeviceWeb.device.supportsPwa) {
        if (!DeviceWeb.isPwaInstalled()) {
          switch (DeviceWeb.device) {
            case Device.androidChrome:
              return _getAndroidChrome();
            case Device.iosSafari:
              return _getSafariIos();
            default:
              return _getGenericMobile();
          }
        } else {
          _scheduleUpdateCheck();
          return widget.home;
        }
      } else {
        return _getNonPwaPlatform();
      }
    }
    return widget.home;
  }
}