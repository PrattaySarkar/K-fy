import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';

import '../../app/app_scope.dart';
import '../../app/app_settings.dart';
import '../../data/local_backup.dart';
import '../../data/subscription_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/money.dart';
import '../../widgets/grain_scaffold.dart';
import '../../widgets/premium_card.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);
    final repo = AppScope.subscriptionsOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([settings, repo]),
      builder: (context, _) {
        return GrainScaffold(
          appBar: AppBar(
            title: Text(
              'Settings',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _SectionLabel('Account & Security'),
              PremiumCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accent.withValues(alpha: 0.25),
                        foregroundColor: AppColors.accent,
                        child: Text(
                          settings.profileName.substring(0, 1),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(
                        settings.profileName,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        settings.profileEmail,
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Biometric Lock',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Require unlock when opening K.fy',
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      value: settings.biometricLock,
                      activeThumbColor: AppColors.accent,
                      onChanged: (value) =>
                          _toggleBiometric(context, settings, value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _SectionLabel('Currency Settings'),
              PremiumCard(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: settings.currencyCode,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    items: [
                      for (final code in Money.supportedCodes)
                        DropdownMenuItem(
                          value: code,
                          child: Text('$code  (${Money.symbol(code)})'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) settings.setCurrencyCode(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _SectionLabel('Notification Systems'),
              PremiumCard(
                child: ListTile(
                  title: Text(
                    'Alerts & reminders',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    settings.globalNotifications
                        ? 'On · trials ${settings.trialExpiryDays}d before'
                        : 'All notifications off',
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              _SectionLabel('Theme Preferences'),
              PremiumCard(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Grain Intensity',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        settings.grainIntensity == GrainIntensity.strong
                            ? 'Strong'
                            : 'Subtle',
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      value: settings.grainIntensity == GrainIntensity.strong,
                      activeThumbColor: AppColors.accent,
                      onChanged: (value) {
                        settings.setGrainIntensity(
                          value
                              ? GrainIntensity.strong
                              : GrainIntensity.subtle,
                        );
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'OLED True-Black',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Pure black background for AMOLED',
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      value: settings.oledTrueBlack,
                      activeThumbColor: AppColors.accent,
                      onChanged: settings.setOledTrueBlack,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _SectionLabel('Data Management'),
              PremiumCard(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Backup Data (Local JSON)',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.file_download_outlined),
                      onTap: () => _backup(context, settings, repo),
                    ),
                    ListTile(
                      title: Text(
                        'Reset App Database',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          color: AppColors.danger,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.delete_forever_outlined,
                        color: AppColors.danger,
                      ),
                      onTap: () => _reset(context, settings, repo),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleBiometric(
    BuildContext context,
    AppSettings settings,
    bool enabled,
  ) async {
    if (!enabled) {
      await settings.setBiometricLock(false);
      return;
    }
    final auth = LocalAuthentication();
    try {
      final supported = await auth.isDeviceSupported();
      if (supported) {
        final ok = await auth.authenticate(
          localizedReason: 'Enable biometric lock for K.fy',
          options: const AuthenticationOptions(biometricOnly: false),
        );
        if (!ok) return;
      }
    } catch (_) {
      // Desktop / unsupported devices still persist the preference.
    }
    await settings.setBiometricLock(true);
  }

  Future<void> _backup(
    BuildContext context,
    AppSettings settings,
    SubscriptionRepository repo,
  ) async {
    final payload = const JsonEncoder.withIndent('  ').convert({
      'settings': settings.toJson(),
      'subscriptions': repo.toJsonList(),
    });
    final path = await writeBackupFile(payload);
    if (!context.mounted) return;
    if (path == null) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text('Backup JSON', style: GoogleFonts.outfit()),
            content: SingleChildScrollView(child: SelectableText(payload)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to $path')),
    );
  }

  Future<void> _reset(
    BuildContext context,
    AppSettings settings,
    SubscriptionRepository repo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Reset database?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'This permanently deletes all subscriptions and resets settings.',
            style: GoogleFonts.outfit(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await repo.reset();
    await settings.reset();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Database reset')),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
