import 'package:flutter/material.dart';

import 'data_validation_page.dart';
import 'global_search_page.dart';
import 'phoenix_l10n.dart';
import 'profile_editor_page.dart';
import 'state/fitness_store.dart';
import 'vault_security_page.dart';

class ExperienceSettingsPage extends StatelessWidget {
  const ExperienceSettingsPage({super.key, required this.store});

  final FitnessStore store;

  Future<void> _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final l = context.l10n;
        final preferences = store.preferences;
        return Scaffold(
          appBar: AppBar(
            title: Text(l.text('ΕΜΠΕΙΡΙΑ PHOENIX', 'PHOENIX EXPERIENCE')),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              Text(
                l.text('Η εφαρμογή στα μέτρα σου', 'The app, tuned to you'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.text(
                  'Γλώσσα, εμφάνιση, προσβασιμότητα και ιδιωτικότητα.',
                  'Language, appearance, accessibility and privacy.',
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(label: l.text('ΓΛΩΣΣΑ', 'LANGUAGE')),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'el', label: Text('Ελληνικά')),
                  ButtonSegment(value: 'en', label: Text('English')),
                ],
                selected: {preferences.languageCode},
                onSelectionChanged: (value) =>
                    store.updatePreferences(languageCode: value.first),
              ),
              const SizedBox(height: 22),
              _SectionTitle(label: l.text('ΘΕΜΑ', 'THEME')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  _ThemeChoice(
                    label: l.text('Iron', 'Iron'),
                    value: 'iron',
                    selected: preferences.themePreset,
                    color: const Color(0xFFFF3D00),
                    onTap: () => store.updatePreferences(themePreset: 'iron'),
                  ),
                  _ThemeChoice(
                    label: l.text('Ocean', 'Ocean'),
                    value: 'ocean',
                    selected: preferences.themePreset,
                    color: const Color(0xFF29B6F6),
                    onTap: () => store.updatePreferences(themePreset: 'ocean'),
                  ),
                  _ThemeChoice(
                    label: l.text('Forest', 'Forest'),
                    value: 'forest',
                    selected: preferences.themePreset,
                    color: const Color(0xFF66BB6A),
                    onTap: () => store.updatePreferences(themePreset: 'forest'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: preferences.highContrast,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) =>
                    store.updatePreferences(highContrast: value),
                secondary: const Icon(Icons.contrast),
                title: Text(l.text('Υψηλή αντίθεση', 'High contrast')),
                subtitle: Text(
                  l.text(
                    'Καθαρότερο μαύρο, φωτεινότερο κείμενο και έντονα περιγράμματα.',
                    'Deeper black, brighter text and stronger outlines.',
                  ),
                ),
              ),
              const Divider(height: 26),
              _SectionTitle(label: l.text('ΑΝΑΤΡΟΦΟΔΟΤΗΣΗ', 'FEEDBACK')),
              SwitchListTile(
                value: preferences.hapticFeedback,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) =>
                    store.updatePreferences(hapticFeedback: value),
                secondary: const Icon(Icons.vibration),
                title: Text(l.text('Απτική ανάδραση', 'Haptic feedback')),
              ),
              SwitchListTile(
                value: preferences.audioCues,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => store.updatePreferences(audioCues: value),
                secondary: const Icon(Icons.volume_up_outlined),
                title: Text(
                  l.text('Ηχητική επιβεβαίωση', 'Audio confirmation'),
                ),
                subtitle: Text(
                  l.text(
                    'Μικρός ήχος μόνο σε σημαντική επιτυχή ενέργεια.',
                    'A short cue only after an important successful action.',
                  ),
                ),
              ),
              const Divider(height: 26),
              _SectionTitle(label: l.text('ΕΡΓΑΛΕΙΑ', 'TOOLS')),
              const SizedBox(height: 7),
              _SettingsTile(
                icon: Icons.person_outline,
                title: l.text('Επεξεργασία προφίλ', 'Edit profile'),
                subtitle: l.text(
                  'Στόχος, εξοπλισμός, χρόνος και περιορισμοί',
                  'Goal, equipment, time and limitations',
                ),
                onTap: () => _push(context, ProfileEditorPage(store: store)),
              ),
              _SettingsTile(
                icon: Icons.manage_search,
                title: l.text('Καθολική αναζήτηση', 'Global search'),
                subtitle: l.text(
                  'Βρες οτιδήποτε μέσα στο Phoenix',
                  'Find anything inside Phoenix',
                ),
                onTap: () => _push(context, GlobalSearchPage(store: store)),
              ),
              _SettingsTile(
                icon: Icons.fact_check_outlined,
                title: l.text(
                  'Κέντρο εγκυρότητας δεδομένων',
                  'Data validation center',
                ),
                subtitle: l.text(
                  'Integrity score και ασφαλής επιδιόρθωση',
                  'Integrity score and safe repair',
                ),
                onTap: () => _push(context, DataValidationPage(store: store)),
              ),
              _SettingsTile(
                icon: store.vaultUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                title: l.text('Ασφάλεια Data Vault', 'Data Vault security'),
                subtitle: store.hasVaultPin
                    ? l.text('Προστασία PIN ενεργή', 'PIN protection enabled')
                    : l.text('Πρόσθεσε τοπικό PIN', 'Add a local PIN'),
                onTap: () => _push(context, VaultSecurityPage(store: store)),
              ),
              if (store.canUndo)
                _SettingsTile(
                  icon: Icons.undo,
                  title: l.text(
                    'Αναίρεση τελευταίας ενέργειας',
                    'Undo last action',
                  ),
                  subtitle: store.undoLabel,
                  onTap: store.undoLastMutation,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      fontSize: 12,
    ),
  );
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final String selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: .18)
              : Colors.white.withValues(alpha: .04),
          border: Border.all(
            color: active ? color : Colors.white12,
            width: active ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 7, backgroundColor: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            if (active) ...[
              const SizedBox(width: 7),
              Icon(Icons.check, size: 17, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
