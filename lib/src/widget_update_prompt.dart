import 'package:flutter/material.dart';
import 'package:pwa_manager/src/widget_base_prompt.dart';

import '../pwa_manager.dart';

/// Dialog offering to reload the app once a new version is detected.
class WidgetUpdatePrompt extends WidgetBasePrompt {
  const WidgetUpdatePrompt({super.key, required super.pwaData, super.home});

  /// Builds an alert dialog with Decline/Accept buttons; accepting the update
  /// reloads the page via [PwaManager.updatePwa].
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(pwaData.updateAvailable),
      content: Text(pwaData.updateLine1),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(pwaData.updateDeclineButton),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            PwaManager.updatePwa();
          },
          child: Text(pwaData.updateAcceptButton),
        ),
      ],
    );
  }
}