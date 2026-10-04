# PWA Manager

_PWA Manager_ is a Flutter package that enables certain Progressive Web App (PWA) functionality for Flutter Web apps. It is principally for Flutter Web projects, but while it won't do anything on other platforms it can still be included. The PWA functionality it provides is:

* It creates landing screens giving the user instructions on how to install their app on Android and iOS, as well as display a QR code on desktop that the user can scan to download the app.

* It can optionally enforce that the app can only be used if installed as a PWA and/or running on a mobile device.

* It will check for updates from the server if the app is installed and prompt the user to update the app.

If you appricate this package. please consider buying me a beer for my effort. It'll encourage me to maintain this project and develop new ones, and I promise to toast to your good health too!

<center><a href='https://ko-fi.com/A1L728693J' target='_blank'><img height='36' style='border:0px;height:36px;' src='buymeabeer.png' border='0' alt='Buy Me a Beer!' /></a></center>

## The PWA Manager Widget Constructor

The _PWA Manager_ widget, should be placed just under the App Widget root (typically `MaterialApp`, or similar). The widget parameters are as follows:

* **enabled** _(bool, default: true)_. Whether the _PWA Manager_ is enabled or not. If not (`false`), the app sub-widgets (see `home`) accessed directly and the Manager carries out no actions. Useful, where one wants to test their app in debug without triggering any of the _PWA Manager_, by setting this value to `!kDebugMode`.

* **requireMobile** _(bool, default: false)_. Sets whether the user is given an option to use the app from the desktop landing screen, without installing on a PWA compatible device. If set to `true` the user will be able to use the app from a desktop browser and without any install.

* **requireInstall** _(bool, default: false)_. Sets whether the user is given an option to use the app from the a landing screen, without installing on a PWA compatible device. If set to `true` the user will be able to use the app from a mobile browser, without any install.

* **customWidgetDesktopPrompt** _(Widget?, default: Inbuilt default values)_. Allows override of the desktop landing screen for a custom one.

* **customWidgetMobilePrompt** _(Widget?, default: Inbuilt default values)_. Allows override of the mobile landing screen for a custom one.

* **customAndroidWidgetInstallPrompt** _(Widget?, default: Inbuilt default values)_. Allows override of the Android installation landing screen.

* **customIosWidgetInstallPrompt**_(Widget?, default: Inbuilt default values)_. Allows override of the iOS installation landing screen.

* **customWidgetUpdatePrompt** _(AlertDialog?)_. Allows override of the update notification dialog.

* **pwaData** _(PwaFormatting, default: Inbuilt default values)_. This object contains all the style and label values for the various screens in _PWA Manager_ in the form of a `PwaFormatting` class. The class comes with default values that if are left null or the class is left null, are used. Useful for localisation purposes.

* **updateCriteria** _(UpdateCriteria, default: UpdateCriteria.any)_. The policy that determines when an update notification is shown. Versions should be in a 0.0.0 format, representing major, minor and patch release numbers. Non-numerical characters will be ignored.

    Options for update notifications are as follows:

    * **UpdateCriteria.noUpdateCheck**. Disabled. User is never notified of updates.
    * **UpdateCriteria.any**. User is notified when a different version is found on the server (triggers for downgrades).
    * **UpdateCriteria.anyUpgrade**. User is notified when the major, minor or patch numbers are higher.
    * **UpdateCriteria.minorUpgrade**. User is notified when the major or minor numbers are higher.
    * **UpdateCriteria.majorUpgrade**. User is notified when the major number is higher.

    **Note:** Updates are detected by reading a `version.json` file that must be served alongside the built app and contains a `version` field in `0.0.0` format (e.g. `{"version": "1.2.3"}`). The first time the installed app checks in, the current server version is cached locally and no prompt is shown; on later visits the server version is compared against the cached one and the user is prompted when it meets the chosen `updateCriteria`. If `version.json` is missing or is not updated on the server, no update prompts will occur.

* **home** _(Widget, required)_. The main root of the PWA app.

## Landing Screen Customisation - Styling and Localisation

While _PWA Manager_ comes with default landing screens, it is possible to customise or completely replace them. They may be constructed or accessed in three ways:

### Default.

_PWA Manager_ already ships with a default English language landing screen flow in place. If you don't require a custom look or localisation, this option is easiest as it requires no extra development.

### Basic Customisation.

Basic customisation can be carried out by passing an optional `PwaFormatting` class in the constructor. With this you can change all the text labels used in the landing screens (thus facilitating localisation) as well as the app `logo`, `backgroundColor`, `textColor`, `primaryBrandColor` and `secondaryBrandColor`.

### Full Customisation.

Alternatively, these screens can be completely be replaced with either stateless or stateful widgets and optionally passed through the constructor. There are a total of five screens:

* **Android Install Prompt**. Used when prompting the user to install on Android via the Chrome browser. The default template for this may be found at `lib/src/widget_android_install_prompt.dart` and a custom version may be passed with the `customAndroidWidgetInstallPrompt` constructor parameter.

* **iOS Install Prompt**. Used when prompting the user to install on iOS via the Safari browser. The default template for this may be found at `lib/src/widget_ios_install_prompt.dart` and a custom version may be passed with the `customIosWidgetInstallPrompt` constructor parameter. Safari 26+ can trigger the native install prompt, while older iOS Safari versions fall back to the manual "Add to Home Screen" instructions.

* **Desktop Install Prompt**. Used when the app is loaded by either an unknown or desktop browser. The default template for this may be found at `lib/src/widget_desktop_prompt.dart` and a custom version may be passed with the `customWidgetDesktopPrompt` constructor parameter.

* **General Mobile Install Prompt**. Used when prompting the user to install from a smartphone with undetermined capabilities. The default template for this may be found at `lib/src/widget_mobile_prompt.dart` and a custom version may be passed with the `customWidgetMobilePrompt` constructor parameter.

* **App Update Prompt**. Used when prompting the user with a dialog to update their already installed PWA. The default template for this may be found at `lib/src/widget_update_prompt.dart` and a custom version may be passed with the `customWidgetUpdatePrompt` constructor parameter. Please note that this widget is accessed as a dialog content rather than a screen.

**Note:** These default templates are internal widgets located in the package's `lib/src/` directory. They are not part of the package's public API, so copy the template you wish to customise into your own app rather than importing it directly.

To allow you to construct custom screens, _PWA Manager_ comes with a number of static methods, accessible from `PwaManager` to facilitate necessary functionality. These are

**PwaManager.promptInstall** Initiates the install PWA process.

**PwaManager.getDownloadQr** Generates a QR Code with a download link to the PWA. Supports custom styling and an embedded logo.

**PwaManager.getWebAddress**
Returns the URL of the PWA. Note that during debug this is naturally on localhost, so it only fully works in release builds.

**PwaManager.updatePwa** Initiates the update PWA process.

## Installation and Quick-start Code

1. First add _PWA Manager_ to your app's YAML file:

```yaml
dependencies:
  pwa_manager:
```

2. Next add the following JavaScript to `/web/index.html`. Where isn't very important, as long as it is somewhere where it will run:

```html
  <script>
    window.addEventListener('beforeinstallprompt', (e) => {
      window.__pwaInstallPrompt = e;
    });
  </script>
```

3. Finally, this example shows a basic implementation and where to insert _PWA Manager_ into the widget tree: 

```dart
void main() =>  runApp(const MyApp());

class Init extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        canvasColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          displayMedium: TextStyle(
            color: Colors.black,
            fontFamily: 'Roboto',
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      home: PwaManager(
        home: const MyAppRoot(),
        pwaData: PwaFormatting(
          appName: "PWA App Test",
          logo: Image.asset('images/logo.png'),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          primaryBrandColor: Colors.red,
          secondaryBrandColor: Colors.amber,
        ),
      ),
    );
  }
}

class MyAppRoot extends StatefulWidget {
  const MyAppRoot({super.key});

  @override
  State<MyAppRoot> createState() => _MyAppRootState();
}

class _MyAppRootState extends State<MyAppRoot> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Hello World!"));
  }
}
```

And that's all there is to it!