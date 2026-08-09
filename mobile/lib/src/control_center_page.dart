import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'achievement_engine.dart';
import 'experience_settings_page.dart';
import 'phoenix_l10n.dart';
import 'profile_editor_page.dart';
import 'state/fitness_store.dart';
import 'vault_security_page.dart';

class ControlCenterPage extends StatelessWidget {
  const ControlCenterPage({super.key, required this.store});

  final FitnessStore store;

  Future<void> _copyBackup(BuildContext context) async {
    if (!store.vaultUnlocked) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VaultSecurityPage(store: store),
        ),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: store.exportBackup()));
    if (!context.mounted) return;
    _message(
      context,
      'Το πλήρες backup αντιγράφηκε. Αποθήκευσέ το σε ασφαλές αρχείο κειμένου.',
    );
  }

  Future<void> _restoreBackup(BuildContext context) async {
    if (!store.vaultUnlocked) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VaultSecurityPage(store: store),
        ),
      );
      return;
    }
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final encoded = clipboard?.text?.trim() ?? '';
    if (!context.mounted) return;
    if (encoded.isEmpty) {
      _message(context, 'Δεν υπάρχει backup στο πρόχειρο.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Επαναφορά backup;'),
        content: const Text(
          'Τα τρέχοντα δεδομένα θα αντικατασταθούν από το backup του '
          'προχείρου. Η ενέργεια δεν αναιρείται χωρίς δεύτερο backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ακύρωση'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Επαναφορά'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await store.restoreBackup(encoded);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _message(context, 'Το Phoenix επανήλθε από το backup.');
    } on FormatException catch (error) {
      if (context.mounted) _message(context, error.message);
    }
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final profile = store.profile;
    final achievements = AchievementEngine.calculate(
      store.data,
      workoutsThisWeek: store.workoutsInCurrentWeek,
      weeklyTarget: store.weeklyWorkoutTarget,
    );
    final unlocked = achievements.where((item) => item.unlocked).length;
    return Scaffold(
      appBar: AppBar(title: const Text('CONTROL CENTER')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(
            'Το Phoenix σου',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            'Προφίλ, αντίγραφα ασφαλείας και milestones σε ένα σημείο.',
            style: TextStyle(color: Colors.white.withValues(alpha: .5)),
          ),
          const SizedBox(height: 20),
          _ProfileSummaryCard(store: store),
          const SizedBox(height: 12),
          _DataVaultCard(
            store: store,
            onCopy: () => _copyBackup(context),
            onRestore: () => _restoreBackup(context),
            onSecurity: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => VaultSecurityPage(store: store),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ACHIEVEMENTS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                '$unlocked/${achievements.length}',
                style: const TextStyle(
                  color: Color(0xFFFF9E80),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 780 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: constraints.maxWidth >= 780 ? 1.7 : 1.35,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) =>
                    _AchievementCard(achievement: achievements[index]),
              );
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExperienceSettingsPage(store: store),
                    ),
                  ),
                  leading: Icon(
                    Icons.tune,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    context.l10n.text(
                      'Εμπειρία & προσβασιμότητα',
                      'Experience & accessibility',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    context.l10n.text(
                      'Γλώσσα, θέμα, feedback, αναζήτηση και ασφάλεια',
                      'Language, theme, feedback, search and security',
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(height: 1),
                ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProfileEditorPage(store: store),
                    ),
                  ),
                  leading: Icon(
                    Icons.manage_accounts_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    context.l10n.text('Επεξεργασία προφίλ', 'Edit profile'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFFFF6E40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LOCAL-FIRST',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Δεν υπάρχει λογαριασμός ή cloud. Το backup περιέχει '
                          'προφίλ, προγράμματα, προπονήσεις, βάρος, διατροφή, '
                          'Spotify και recovery check-ins.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (profile == null) const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final profile = store.profile;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF35130D), Color(0xFF15110F)],
        ),
        border: Border.all(color: const Color(0x55FF3D00)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFFFF6E40)),
              SizedBox(width: 9),
              Text(
                'ΠΡΟΣΩΠΙΚΟ ΠΡΟΦΙΛ',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ProfileChip(
                icon: Icons.flag_outlined,
                label: profile?.goal ?? 'Preview',
              ),
              _ProfileChip(
                icon: Icons.monitor_weight_outlined,
                label: '${store.currentWeightKilograms.toStringAsFixed(1)} kg',
              ),
              _ProfileChip(
                icon: Icons.calendar_view_week,
                label: '${store.weeklyWorkoutTarget} ημέρες',
              ),
              _ProfileChip(
                icon: Icons.fitness_center,
                label: profile?.equipment ?? 'Προεπιλογή',
              ),
              _ProfileChip(
                icon: Icons.timer_outlined,
                label: '${profile?.sessionMinutes ?? 45} λεπτά',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFFF9E80)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DataVaultCard extends StatelessWidget {
  const _DataVaultCard({
    required this.store,
    required this.onCopy,
    required this.onRestore,
    required this.onSecurity,
  });

  final FitnessStore store;
  final VoidCallback onCopy;
  final VoidCallback onRestore;
  final VoidCallback onSecurity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  store.vaultUnlocked
                      ? Icons.lock_open_outlined
                      : Icons.lock_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 9),
                const Text(
                  'DATA VAULT',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onSecurity,
                  tooltip: context.l10n.text('Ασφάλεια', 'Security'),
                  icon: const Icon(Icons.shield_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${store.data.logs.length} προπονήσεις • '
              '${store.data.weights.length} βάρη • '
              '${store.data.meals.length} γεύματα • '
              '${store.data.recoveryChecks.length} check-ins',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .55),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            if (!store.vaultUnlocked) ...[
              FilledButton.icon(
                onPressed: onSecurity,
                icon: const Icon(Icons.password),
                label: Text(
                  context.l10n.text('Ξεκλείδωμα με PIN', 'Unlock with PIN'),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: store.vaultUnlocked ? onCopy : null,
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Αντιγραφή backup'),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: store.vaultUnlocked ? onRestore : null,
                    icon: const Icon(Icons.restore),
                    label: const Text('Επαναφορά'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final PhoenixAchievement achievement;

  IconData get _icon => switch (achievement.kind) {
    AchievementKind.firstSession => Icons.local_fire_department,
    AchievementKind.ironWeek => Icons.calendar_month,
    AchievementKind.fiftySets => Icons.layers,
    AchievementKind.tenSessions => Icons.workspace_premium,
    AchievementKind.recoveryHabit => Icons.battery_charging_full,
    AchievementKind.nutritionHabit => Icons.restaurant,
  };

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    final color = unlocked ? const Color(0xFFFF6E40) : Colors.white24;
    return Card(
      color: unlocked ? const Color(0xFF21120F) : const Color(0xFF111111),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, color: color),
                const Spacer(),
                Icon(
                  unlocked ? Icons.verified : Icons.lock_outline,
                  color: color,
                  size: 18,
                ),
              ],
            ),
            const Spacer(),
            Text(
              achievement.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              achievement.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: achievement.progress,
              minHeight: 4,
              backgroundColor: Colors.white10,
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 4),
            Text(
              '${achievement.current.clamp(0, achievement.target)}/${achievement.target}',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
