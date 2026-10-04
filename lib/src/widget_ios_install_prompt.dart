import 'package:flutter/material.dart';

import 'widget_base_prompt.dart';

/// Prompt shown to iOS Safari visitors: logo, an install button (iOS 16.4+
/// supports the prompt API) and manual "Add to Home Screen" instructions.
class WidgetIosInstallPrompt extends WidgetBasePrompt {
  const WidgetIosInstallPrompt({super.key, super.home, required super.pwaData});

  /// Assembles the iOS install prompt layout on the base screen.
  @override
  Widget build(BuildContext context) {
    return buildScreen(
      context,
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            setDebugHeader('iOS-Safari'),
            setLogo(context),
            setVerticalSpacer(),
            setTextLine(pwaData.iosInstallLine1),
            setVerticalSpacer(),
            setInstallButton(200.0),
            setVerticalSpacer(),
            setTextLine(pwaData.iosInstallLine2),
            setVerticalSpacer(),
            setInstructions(pwaData.iosInstallInstructions),
            setVerticalSpacer(30.0),
            setPassthrough(context),
          ],
        ),
      ),
    );
  }
}