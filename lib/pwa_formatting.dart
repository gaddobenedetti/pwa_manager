import 'package:flutter/material.dart';

/// Holds all user-facing text, colors and a logo used by the default prompt
/// widgets. Pass an instance to [PwaManager.pwaData].
class PwaFormatting {
  /// Logo image used on the prompt screens and embedded in the QR code.
  final Image? logo;

  /// Name of the app shown as a heading on prompt screens.
  final String appName;

  /// Background color of the prompt screens.
  final Color backgroundColor;

  /// Primary text color on the prompt screens.
  final Color textColor;

  /// Accent color used for headings and buttons.
  final Color primaryBrandColor;

  /// Secondary accent color used for the QR card and icons.
  final Color secondaryBrandColor;

  /// Label of the link that lets the user bypass installation.
  final String passToHome;

  /// Text shown on the desktop prompt inviting the user to scan the QR code.
  final String desktopDownloadPrompt;

  /// First line of the iOS install prompt.
  final String iosInstallLine1;

  /// Second line of the iOS install prompt (manual instructions intro).
  final String iosInstallLine2;

  /// Numbered manual instructions for installing on iOS.
  final List<String> iosInstallInstructions;

  /// First line of the Android install prompt.
  final String androidInstallLine1;

  /// Second line of the Android install prompt (manual instructions intro).
  final String androidInstallLine2;

  /// Numbered manual instructions for installing on Android.
  final List<String> androidInstallInstructions;

  /// Heading of the generic mobile prompt.
  final String addToHome;

  /// Recommendation text of the generic mobile prompt.
  final String mobileReccomendation;

  /// Further guidance shown on the generic mobile prompt.
  final String mobileInstruction;

  /// Title of the update-available dialog.
  final String updateAvailable;

  /// Body text of the update-available dialog.
  final String updateLine1;

  /// Label of the dialog button that accepts the update.
  final String updateAcceptButton;

  /// Label of the dialog button that dismisses the update.
  final String updateDeclineButton;

  const PwaFormatting({
    this.logo,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.primaryBrandColor = Colors.red,
    this.secondaryBrandColor = Colors.black,
    this.appName = "",
    this.passToHome = "Continue without installing",
    this.desktopDownloadPrompt =
        "Scan this QR code with your smartphone to download the app.",
    this.iosInstallLine1 =
        "Install this app to your iOS device by pressing the button below.",
    this.iosInstallLine2 =
        "Alternatively you can install manually with your smartphone's Safari browser by following the following instructions:",
    this.iosInstallInstructions = const [
      "Open the link in Safari.",
      "Tap on the 'share' button.",
      "Select 'Add to Home screen'.",
    ],
    this.androidInstallLine1 =
        "Install this app to your Android device by pressing the button below.",
    this.androidInstallLine2 =
        "Alternatively you can install manually with your smartphone's Chrome browser by following the following instructions:",
    this.androidInstallInstructions = const [
      "Open the link in Chrome.",
      "Tap on into 'Settings'.",
      "Select 'Add to Home screen'.",
    ],

    this.addToHome = "Add to Home Screen",
    this.mobileReccomendation =
        "To use this app it is reccomended that it is installed as a Progressive Web App (PWA).",
    this.mobileInstruction =
        "This app works best when installed from Safari (iOS) or Chrome (Android)",

    this.updateAvailable = "Update Available",
    this.updateLine1 = "A new version is ready. Reload to update.",
    this.updateAcceptButton = "Update",
    this.updateDeclineButton = "Cancel",
  });
}