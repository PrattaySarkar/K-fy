import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app_scope.dart';
import 'app/app_settings.dart';
import 'bootstrap.dart';
import 'data/subscription_repository.dart';
import 'screens/home/home_screen.dart';
import 'screens/lock/lock_gate.dart';
import 'screens/splash/splash_overlay.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await bootstrap();
  final settings = AppSettings();
  final subscriptions = SubscriptionRepository();
  await subscriptions.seedIfEmpty();
  runApp(
    KfyApp(
      settings: settings,
      subscriptions: subscriptions,
    ),
  );
}

class KfyApp extends StatefulWidget {
  const KfyApp({
    super.key,
    required this.settings,
    required this.subscriptions,
    this.showSplash = true,
  });

  final AppSettings settings;
  final SubscriptionRepository subscriptions;
  final bool showSplash;

  @override
  State<KfyApp> createState() => _KfyAppState();
}

class _KfyAppState extends State<KfyApp> {
  late bool _showSplash = widget.showSplash;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: widget.settings,
      subscriptions: widget.subscriptions,
      child: ListenableBuilder(
        listenable: widget.settings,
        builder: (context, _) {
          final background = widget.settings.oledTrueBlack
              ? AppColors.oledBackground
              : AppColors.background;
          return MaterialApp(
            title: 'K.fy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(background: background),
            home: Stack(
              fit: StackFit.expand,
              children: [
                LockGate(child: const HomeScreen()),
                if (_showSplash)
                  SplashOverlay(
                    onFinished: () => setState(() => _showSplash = false),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
