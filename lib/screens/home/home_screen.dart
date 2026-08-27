import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_scope.dart';
import '../../models/subscription.dart';
import '../../theme/app_colors.dart';
import '../../widgets/grain_scaffold.dart';
import '../../widgets/swipe_delete.dart';
import '../add_subscription/add_subscription_page.dart';
import '../settings/settings_screen.dart';
import 'widgets/add_subscription_cta.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/pill_tab_bar.dart';
import 'widgets/reminder_card.dart';
import 'widgets/savings_hero_card.dart';
import 'widgets/subscriptions_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _onAddSubscription(
    BuildContext context,
    BuildContext tabContext,
  ) async {
    final draft = await showAddSubscriptionSheet(context);
    if (draft == null || !context.mounted) return;

    final item = draft.toSubscription(id: const Uuid().v4());
    await AppScope.subscriptionsOf(context).upsert(item);

    if (!tabContext.mounted) return;
    DefaultTabController.of(tabContext).animateTo(item.isTrial ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);
    final repo = AppScope.subscriptionsOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([settings, repo]),
      builder: (context, _) {
        return DefaultTabController(
          length: 3,
          child: Builder(
            builder: (tabContext) {
              return GrainScaffold(
                bottomNavigationBar: AddSubscriptionCta(
                  onPressed: () => _onAddSubscription(context, tabContext),
                ),
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HomeAppBar(onMenuTap: () => _openSettings(context)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: SavingsHeroCard(amount: settings.savedTillDate),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: PillTabBar(),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _SubscriptionList(
                              items: repo.reminders,
                              emptyLabel: 'Nothing here yet',
                            ),
                            SubscriptionsTab(items: repo.paidSubscriptions),
                            _SubscriptionList(
                              items: repo.history,
                              emptyLabel: 'No history yet',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SubscriptionList extends StatelessWidget {
  const _SubscriptionList({
    required this.items,
    required this.emptyLabel,
  });

  final List<Subscription> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: GoogleFonts.outfit(color: AppColors.textMuted),
        ),
      );
    }

    final repo = AppScope.subscriptionsOf(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 22),
      itemBuilder: (context, index) {
        final item = items[index];
        return SwipeDelete(
          id: item.id,
          label: item.name,
          onDelete: () => repo.delete(item.id),
          child: ReminderCard(item: item),
        );
      },
    );
  }
}
