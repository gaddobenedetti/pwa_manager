import 'package:flutter/material.dart';

import 'widget_base_prompt.dart';

/// Prompt shown to generic smartphones: logo, a recommendation to install the
/// app and a pass-through link.
class WidgetMobilePrompt extends WidgetBasePrompt {
  const WidgetMobilePrompt({super.key, super.home, required super.pwaData});

  /// Assembles the generic mobile prompt layout on the base screen.
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
            setDebugHeader('Generic Smartphone'),
            setLogo(context),
            setVerticalSpacer(),
            customHeader(pwaData.addToHome),
            setVerticalSpacer(20.0),
            setTextLine(pwaData.mobileReccomendation),
            setVerticalSpacer(30.0),
            setBoxedText(pwaData.mobileInstruction),
            setVerticalSpacer(30.0),
            setPassthrough(context),
          ],
        ),
      ),
    );
  }
}