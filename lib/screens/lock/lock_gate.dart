import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';

import '../../app/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/kfy_logo.dart';
import '../../widgets/film_grain.dart';

class LockGate extends StatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _locked = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncLock(true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncLock(false);
    } else if (state == AppLifecycleState.paused) {
      final enabled = AppScope.settingsOf(context).biometricLock;
      if (enabled) setState(() => _locked = true);
    }
  }

  void _syncLock(bool authenticateNow) {
    final enabled = AppScope.settingsOf(context).biometricLock;
    if (!enabled) {
      setState(() => _locked = false);
      return;
    }
    setState(() => _locked = true);
    if (authenticateNow) _unlock();
  }

  Future<void> _unlock() async {
    if (_busy) return;
    setState(() => _busy = true);
    var ok = false;
    try {
      final supported = await _auth.isDeviceSupported();
      if (supported) {
        ok = await _auth.authenticate(
                localizedReason: 'Unlock K.fy',
          options: const AuthenticationOptions(biometricOnly: false),
        );
      } else {
        ok = true;
      }
    } catch (_) {
      ok = true;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _locked = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        if (!settings.biometricLock || !_locked) return widget.child;
        return GrainBackdrop(
          oled: settings.oledTrueBlack,
          intensity: settings.grainIntensity,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const KfyLogo(size: 64),
                const SizedBox(height: 28),
                Text(
                  'Locked',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _unlock,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: Text(
                    _busy ? 'Unlocking…' : 'Unlock',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
