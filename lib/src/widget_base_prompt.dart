import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../pwa_formatting.dart';
import '../pwa_manager.dart';
import 'pwa_toolkit.dart';

/// Shared base for all prompt screens, providing generic building blocks
/// (background, text, logo, QR, install button, instructions, pass-through).
class WidgetBasePrompt extends StatelessWidget {
  /// The app widget to navigate to via the "pass through" link.
  final Widget? home;

  /// Formatting data (text, colors, logo) used to build the prompt.
  final PwaFormatting pwaData;

  const WidgetBasePrompt({super.key, required this.pwaData, this.home});

  /// Wraps [body] with the prompt's default text style, background color and a
  /// centered scrollable layout.
  Widget buildScreen(BuildContext context, Widget body) {
    return DefaultTextStyle(
      style: TextStyle(
        color: pwaData.textColor,
        fontSize: 16.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none, // Removes the ugly yellow underline
      ),
      child: Container(
        color: pwaData.backgroundColor,
        child: Center(child: SingleChildScrollView(child: body)),
      ),
    );
  }

  /// A centered line of default-colored text (hidden when [text] is empty).
  Widget setTextLine(String text) => text.isEmpty
      ? SizedBox(width: 0.0, height: 0.0)
      : Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: pwaData.textColor),
        );

  /// A card with semi-transparent secondary color wrapping a [setTextLine].
  Widget setBoxedText(String text) => text.isEmpty
      ? SizedBox(width: 0.0, height: 0.0)
      : Card(
          color: pwaData.secondaryBrandColor.withValues(alpha: 0.5),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: setTextLine(text),
          ),
        );

  /// An amber debug-only header (visible only in debug builds).
  Widget setDebugHeader(String text) => kDebugMode && text.isNotEmpty
      ? Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.amber),
        )
      : SizedBox(width: 0.0, height: 0.0);

  /// A bold heading using the primary brand color.
  Widget customHeader(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 24.0,
      color: pwaData.primaryBrandColor,
      fontWeight: FontWeight.bold,
    ),
  );

  /// The app name rendered as a bold title (hidden when empty).
  Widget setAppName() => pwaData.appName.isEmpty
      ? SizedBox(width: 0.0, height: 0.0)
      : Text(
          pwaData.appName,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        );

  /// The configured logo fitted into a square up to 150x150 px.
  Widget setLogo(BuildContext context) {
    double maxSize = 150.0;
    Size screenSize = MediaQuery.of(context).size;
    double size = screenSize.width * 0.8 > maxSize
        ? maxSize
        : screenSize.width * 0.8;
    return pwaData.logo == null
        ? SizedBox(width: 0.0, height: 0.0)
        : Image(
            image: pwaData.logo!.image,
            height: size,
            width: size,
            fit: BoxFit.contain,
          );
  }

  /// A card containing a QR code (up to 300x300 px) that encodes the current
  /// web address, embedding the pwaData logo in its centre.
  Widget setQR(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double qrWidth = screenSize.width * 0.8 > 300.0
        ? 300.0
        : screenSize.width * 0.8;
    return Card(
      color: pwaData.secondaryBrandColor,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: PwaManager.getDownloadQr(
          size: qrWidth,
          eyeColor: pwaData.primaryBrandColor,
          logo: pwaData.logo?.image,
        ),
      ),
    );
  }

  /// A tappable download button that triggers the native install prompt.
  Widget setInstallButton(double size) => Padding(
    padding: EdgeInsets.all(8.0),
    child: Card(
      color: pwaData.primaryBrandColor,
      child: IconButton(
        icon: Icon(
          Icons.download,
          size: size,
          color: pwaData.secondaryBrandColor,
        ),
        onPressed: () => PwaToolkit.promptInstall(),
      ),
    ),
  );

  /// A numbered column of installation instruction rows.
  Widget setInstructions(List<String> instructions) {
    if (instructions.isEmpty) return SizedBox(width: 0.0, height: 0.0);
    List<Row> rows = [];
    for (int i = 0; i < instructions.length; i++) {
      rows.add(
        Row(
          children: [
            Padding(padding: EdgeInsets.all(8.0), child: Text("${i + 1}. ")),
            Padding(padding: EdgeInsets.all(8.0), child: Text(instructions[i])),
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: rows,
    );
  }

  /// An empty spacer of the given height (default 16.0).
  Widget setVerticalSpacer([double height = 16.0]) => SizedBox(height: height);

  /// A pass-through link navigating to [home], faded text; hidden when
  /// [home] is null or installation is mandatory.
  Widget setPassthrough(BuildContext context) {
    if (home == null) {
      return SizedBox(width: 0.0, height: 0.0);
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => home!),
          ),
          child: Text(
            pwaData.passToHome,
            style: TextStyle(color: pwaData.textColor.withValues(alpha: 0.5)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}