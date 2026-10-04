import 'package:flutter/material.dart';

import 'widget_base_prompt.dart';

/// Prompt shown to desktop browsers / non-PWA platforms: app name, a QR code
/// for the smartphone to scan, and a pass-through link.
class WidgetDesktopPrompt extends WidgetBasePrompt {
  const WidgetDesktopPrompt({super.key, super.home, required super.pwaData});

  /// Assembles the desktop prompt layout on the base screen.
  @override
  Widget build(BuildContext context) {
    return buildScreen(
      context,
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            setDebugHeader('Non-PWA browsers & desktops'),
            setAppName(),
            setTextLine(pwaData.desktopDownloadPrompt),
            setQR(context),
            setPassthrough(context),
          ],
        ),
      ),
    );
  }
}