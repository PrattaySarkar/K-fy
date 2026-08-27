import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/grain_scaffold.dart';
import '../../widgets/premium_card.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  static const _leadDays = [1, 3, 7];

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final enabled = settings.globalNotifications;
        final sliderIndex = _leadDays
            .indexOf(settings.trialExpiryDays)
            .clamp(0, _leadDays.length - 1);

        return GrainScaffold(
          appBar: AppBar(
            title: Text(
              'Notifications',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              PremiumCard(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Global Notifications',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Master switch for every alert',
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  value: settings.globalNotifications,
                  activeThumbColor: AppColors.accent,
                  onChanged: settings.setGlobalNotifications,
                ),
              ),
              const SizedBox(height: 18),
              PremiumCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Opacity(
                  opacity: enabled ? 1 : 0.45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trial Expiry Alerts',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_leadDays[sliderIndex]} day${_leadDays[sliderIndex] == 1 ? '' : 's'} before',
                        style: GoogleFonts.outfit(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Slider(
                        value: sliderIndex.toDouble(),
                        min: 0,
                        max: (_leadDays.length - 1).toDouble(),
                        divisions: _leadDays.length - 1,
                        label: '${_leadDays[sliderIndex]} days before',
                        onChanged: enabled
                            ? (value) {
                                settings.setTrialExpiryDays(
                                  _leadDays[value.round()],
                                );
                              }
                            : null,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final days in _leadDays)
                            Text(
                              '${days}d',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PremiumCard(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Upcoming Renewal Reminders',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                  ),
                  value: enabled && settings.renewalReminders,
                  activeThumbColor: AppColors.accent,
                  onChanged: enabled ? settings.setRenewalReminders : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
