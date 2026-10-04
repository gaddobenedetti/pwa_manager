import 'package:flutter/material.dart';

import 'widget_base_prompt.dart';

/// Prompt shown to Android Chrome visitors: logo, a download/install button
/// and manual "Add to Home Screen" instructions.
class WidgetAndroidInstallPrompt extends WidgetBasePrompt {
  const WidgetAndroidInstallPrompt({
    super.key,
    super.home,
    required super.pwaData,
  });

  /// Assembles the Android install prompt layout on the base screen.
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
            setDebugHeader('Android-Chrome'),
            setLogo(context),
            setVerticalSpacer(),
            setTextLine(pwaData.androidInstallLine1),
            setVerticalSpacer(),
            setInstallButton(200.0),
            setVerticalSpacer(),
            setTextLine(pwaData.androidInstallLine2),
            setVerticalSpacer(),
            setInstructions(pwaData.androidInstallInstructions),
            setVerticalSpacer(30.0),
            setPassthrough(context),
          ],
        ),
      ),
    );
  }
}