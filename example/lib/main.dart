import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pwa_manager/pwa_manager.dart';
import 'package:pwa_manager/pwa_formatting.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PWA Example',
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
        enabled: true,
        home: const MyHomePage(title: 'PWA Example'),
        pwaData: PwaFormatting(
          appName: "PWA App Test",
          logo: Image.asset('assets/images/logo.png'),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          primaryBrandColor: Colors.red,
          secondaryBrandColor: Colors.amber,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _wakeLockActive = false;
  StreamSubscription<PwaScreenState>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = PwaManager.onScreenStateChanged.listen(_onStateChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onStateChanged(PwaScreenState state) {
    if (!mounted) return;
    debugPrint("Screen State: ${state.name}");
  }

  Future<void> _enableIdleDetection() async {
    final bool started = await PwaManager.startIdleDetection();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          started
              ? 'Idle detection started'
              : 'Idle detection is unavailable or was denied',
        ),
      ),
    );
  }

  Future<void> _toggleWakeLock() async {
    if (_wakeLockActive) {
      await PwaManager.allowScreenOff();
    } else {
      await PwaManager.keepScreenOn();
    }
    if (!mounted) return;
    setState(() => _wakeLockActive = PwaManager.wakeLockActive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder<PwaScreenState>(
          initialData: PwaManager.screenState,
          stream: PwaManager.onScreenStateChanged,
          builder: (context, snapshot) {
            final PwaScreenState state =
                snapshot.data ?? PwaScreenState.unknown;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Screen state:'),
                Text(
                  state.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  PwaManager.supportsIdleDetection
                      ? 'Idle/lock detection is supported'
                      : 'Idle/lock detection is unavailable in this browser',
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: PwaManager.supportsIdleDetection
                      ? _enableIdleDetection
                      : null,
                  child: const Text('Enable idle detection'),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: _toggleWakeLock,
                  child: Text(
                    _wakeLockActive ? 'Allow screen off' : 'Keep screen on',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
