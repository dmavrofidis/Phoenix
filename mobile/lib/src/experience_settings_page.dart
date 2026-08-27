import 'package:flutter/material.dart';

import 'data_validation_page.dart';
import 'global_search_page.dart';
import 'phoenix_l10n.dart';
import 'profile_editor_page.dart';
import 'state/fitness_store.dart';
import 'vault_security_page.dart';

class ExperienceSettingsPage extends StatelessWidget {
  const ExperienceSettingsPage({
    super.key,
    required this.store,
    this.focusTheme = false,
  });

  final FitnessStore store;
  final bool focusTheme;

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
            title: Text(
              focusTheme
                  ? l.text('ΧΡΩΜΑΤΑ & ΘΕΜΑ', 'COLORS & THEME')
                  : l.text('ΕΜΠΕΙΡΙΑ PHOENIX', 'PHOENIX EXPERIENCE'),
            ),
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
              if (focusTheme) ..._themeSection(context),
              _SectionTitle(label: l.text('ΓΛΩΣΣΑ', 'LANGUAGE')),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'el', label: Text('Ελληνικά')),
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'de', label: Text('Deutsch')),
                  ButtonSegment(value: 'es', label: Text('Español')),
                ],
                selected: {preferences.languageCode},
                onSelectionChanged: (value) =>
                    store.updatePreferences(languageCode: value.first),
              ),
              if (!focusTheme) ...[
                const SizedBox(height: 22),
                ..._themeSection(context),
              ],
              const Divider(height: 26),
              _SectionTitle(label: l.text('ΕΥΚΟΛΟΤΕΡΗ ΧΡΗΣΗ', 'EASIER TO USE')),
              const SizedBox(height: 8),
              Text(
                l.text('Γρήγορες επιλογές', 'Quick accessibility choices'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.text_increase, size: 18),
                    label: Text(l.text('Μεγαλύτερα γράμματα', 'Larger text')),
                    onPressed: () => store.updatePreferences(textScale: 1.4),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.spa_outlined, size: 18),
                    label: Text(l.text('Ήρεμη προβολή', 'Calm view')),
                    onPressed: () {
                      store.updatePreferences(
                        themePreset: 'sage',
                        reducedMotion: true,
                      );
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.contrast, size: 18),
                    label: Text(l.text('Υψηλή αντίθεση', 'High contrast')),
                    onPressed: () =>
                        store.updatePreferences(highContrast: true),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.touch_app_outlined, size: 18),
                    label: Text(
                      l.text('Μεγαλύτερα κουμπιά', 'Larger controls'),
                    ),
                    onPressed: () =>
                        store.updatePreferences(touchTargetScale: 1.5),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '${l.text('Κλίμακα κειμένου', 'Text scale')} ${(preferences.textScale * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Slider(
                value: preferences.textScale,
                min: 1,
                max: 1.6,
                divisions: 6,
                label: '${(preferences.textScale * 100).round()}%',
                onChanged: (value) => store.updatePreferences(textScale: value),
              ),
              SwitchListTile(
                value: preferences.reducedMotion,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) =>
                    store.updatePreferences(reducedMotion: value),
                secondary: const Icon(Icons.motion_photos_off_outlined),
                title: Text(l.text('Μειωμένη κίνηση', 'Reduced motion')),
                subtitle: Text(
                  l.text(
                    'Περιορίζει τις κινήσεις και τις αλλαγές οθόνης που μπορεί να κουράζουν.',
                    'Removes page transitions and exposes disableAnimations.',
                  ),
                ),
              ),
              Text(
                l.text('Παλέτα χρωματικής όρασης', 'Color-vision palette'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final mode in const [
                    ('standard', 'Κανονική'),
                    ('deuteranopia', 'Δυσκολία σε κόκκινο–πράσινο'),
                    ('tritanopia', 'Δυσκολία σε μπλε–κίτρινο'),
                  ])
                    ChoiceChip(
                      label: Text(mode.$2),
                      selected: preferences.colorVisionMode == mode.$1,
                      onSelected: (_) =>
                          store.updatePreferences(colorVisionMode: mode.$1),
                    ),
                ],
              ),
              SwitchListTile(
                value: preferences.readabilityFont,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) =>
                    store.updatePreferences(readabilityFont: value),
                secondary: const Icon(Icons.text_fields),
                title: Text(
                  l.text('Πιο ευανάγνωστα γράμματα', 'Readability typography'),
                ),
                subtitle: Text(
                  l.text(
                    'Χρησιμοποιεί απλή γραμματοσειρά για πιο ξεκούραστη ανάγνωση.',
                    'Uses readable system-font fallbacks.',
                  ),
                ),
              ),
              SwitchListTile(
                value: preferences.oneHandMode,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) =>
                    store.updatePreferences(oneHandMode: value),
                secondary: const Icon(Icons.back_hand_outlined),
                title: Text(l.text('Λειτουργία ενός χεριού', 'One-hand mode')),
                subtitle: Text(
                  l.text(
                    'Κρατά τις βασικές ενέργειες της προπόνησης χαμηλά στην οθόνη.',
                    'Keeps primary workout actions low on the screen.',
                  ),
                ),
              ),
              SwitchListTile(
                value: preferences.voiceLabels,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) =>
                    store.updatePreferences(voiceLabels: value),
                secondary: const Icon(Icons.record_voice_over_outlined),
                title: Text(
                  l.text(
                    'Καθαρά ονόματα για φωνητικό έλεγχο',
                    'Voice-friendly labels',
                  ),
                ),
                subtitle: Text(
                  l.text(
                    'Βοηθά τον φωνητικό έλεγχο και την ανάγνωση της οθόνης.',
                    'Keeps action names explicit for voice control and readers.',
                  ),
                ),
              ),
              Text(
                '${l.text('Μέγεθος κουμπιών', 'Control size')} ${(preferences.touchTargetScale * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Slider(
                value: preferences.touchTargetScale,
                min: 1,
                max: 1.5,
                divisions: 2,
                label: '${(preferences.touchTargetScale * 100).round()}%',
                onChanged: (value) =>
                    store.updatePreferences(touchTargetScale: value),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.accessibility_new),
                  title: Text(
                    l.text(
                      'Όλες οι βοήθειες είναι διαθέσιμες',
                      'All accessibility aids are available',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    l.text(
                      'Μεγάλα γράμματα και κουμπιά, λιγότερη κίνηση, ασφαλή χρώματα και υποστήριξη ανάγνωσης οθόνης.',
                      'Large text and controls, reduced motion, safer colors and screen-reader support.',
                    ),
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
                onChanged: (value) => store.updatePreferences(
                  audioCues: value,
                  audioCueStyle: value ? preferences.audioCueStyle : 'minimal',
                ),
                secondary: const Icon(Icons.volume_up_outlined),
                title: Text(
                  l.text(
                    'Ήχος και φωνητική καθοδήγηση',
                    'Audio and voice guidance',
                  ),
                ),
                subtitle: Text(
                  l.text(
                    'Διάλεξε απλούς ήχους ή φωνή μέσα στην προπόνηση.',
                    'Choose simple cues or spoken workout guidance.',
                  ),
                ),
              ),
              if (preferences.audioCues) ...[
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  key: const ValueKey('audio-guidance-style'),
                  segments: [
                    ButtonSegment(
                      value: 'minimal',
                      icon: const Icon(Icons.music_note_outlined),
                      label: Text(l.text('Απλοί ήχοι', 'Simple cues')),
                    ),
                    ButtonSegment(
                      value: 'coach',
                      icon: const Icon(Icons.record_voice_over_outlined),
                      label: Text(l.text('Φωνή', 'Voice')),
                    ),
                  ],
                  selected: {
                    preferences.audioCueStyle == 'coach' ? 'coach' : 'minimal',
                  },
                  onSelectionChanged: (value) =>
                      store.updatePreferences(audioCueStyle: value.first),
                ),
              ],
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
                  'Έλεγχος και ασφαλής διόρθωση των τοπικών δεδομένων',
                  'Integrity score and safe repair',
                ),
                onTap: () => _push(context, DataValidationPage(store: store)),
              ),
              _SettingsTile(
                icon: store.vaultUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                title: l.text(
                  'Ασφάλεια ιδιωτικών δεδομένων',
                  'Data Vault security',
                ),
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

  List<Widget> _themeSection(BuildContext context) {
    final l = context.l10n;
    final preferences = store.preferences;
    const choices = [
      ('sage', 'Sage', 'Ήρεμο πράσινο', 'Soft green', Color(0xFF9CB9A5), true),
      ('sky', 'Sky', 'Απαλό γαλάζιο', 'Soft blue', Color(0xFF8DB7C8), true),
      ('sand', 'Sand', 'Ζεστό μπεζ', 'Warm beige', Color(0xFFD2B08A), true),
      (
        'iron',
        'Phoenix',
        'Απαλό κοραλί',
        'Soft coral',
        Color(0xFFE4937F),
        false,
      ),
      ('ocean', 'Ocean', 'Ήρεμο μπλε', 'Calm blue', Color(0xFF5CA9C9), false),
      (
        'forest',
        'Forest',
        'Βαθύ πράσινο',
        'Deep green',
        Color(0xFF73A97A),
        false,
      ),
      (
        'violet',
        'Violet',
        'Απαλό μωβ',
        'Soft purple',
        Color(0xFFA995D2),
        false,
      ),
      ('rose', 'Rose', 'Ήρεμο ροζ', 'Muted pink', Color(0xFFD98FAE), false),
      ('gold', 'Gold', 'Απαλό χρυσό', 'Soft gold', Color(0xFFC9A45C), false),
    ];
    return [
      _SectionTitle(label: l.text('ΧΡΩΜΑΤΑ & ΘΕΜΑ', 'COLORS & THEME')),
      const SizedBox(height: 8),
      _LiveThemePreview(
        title: l.text('Έτσι θα φαίνεται', 'Live preview'),
        detail: l.text(
          'Η αλλαγή εφαρμόζεται αμέσως και αποθηκεύεται μόνο σε αυτή τη συσκευή.',
          'Changes apply immediately and stay only on this device.',
        ),
      ),
      const SizedBox(height: 10),
      Text(
        l.text(
          'Οι τρεις πρώτες επιλογές είναι σχεδιασμένες για πιο ήρεμη καθημερινή εμπειρία.',
          'The first three options are designed for a calmer everyday experience.',
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth >= 620
              ? (constraints.maxWidth - 20) / 3
              : (constraints.maxWidth - 10) / 2;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final choice in choices)
                SizedBox(
                  width: itemWidth,
                  child: _ThemeChoice(
                    label: choice.$2,
                    detail: l.text(choice.$3, choice.$4),
                    value: choice.$1,
                    selected: preferences.themePreset,
                    color: choice.$5,
                    calm: choice.$6,
                    onTap: () =>
                        store.updatePreferences(themePreset: choice.$1),
                  ),
                ),
            ],
          );
        },
      ),
      if (preferences.colorVisionMode != 'standard') ...[
        const SizedBox(height: 10),
        Text(
          l.text(
            'Η παλέτα χρωματικής όρασης παραμένει ενεργή και έχει προτεραιότητα για ασφαλή αντίθεση.',
            'Your color-vision palette remains active and takes priority for safe contrast.',
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
      const SizedBox(height: 10),
      SwitchListTile(
        value: preferences.highContrast,
        contentPadding: EdgeInsets.zero,
        onChanged: (value) => store.updatePreferences(highContrast: value),
        secondary: const Icon(Icons.contrast),
        title: Text(l.text('Υψηλή αντίθεση', 'High contrast')),
        subtitle: Text(
          l.text(
            'Καθαρότερο μαύρο, φωτεινότερο κείμενο και έντονα περιγράμματα.',
            'Deeper black, brighter text and stronger outlines.',
          ),
        ),
      ),
      const SizedBox(height: 22),
    ];
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
    required this.detail,
    required this.value,
    required this.selected,
    required this.color,
    required this.calm,
    required this.onTap,
  });

  final String label;
  final String detail;
  final String value;
  final String selected;
  final Color color;
  final bool calm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return Semantics(
      button: true,
      selected: active,
      label: 'Theme $label',
      child: InkWell(
        key: ValueKey('theme-choice-$value'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: .16)
                : Theme.of(context).colorScheme.surfaceContainer,
            border: Border.all(
              color: active
                  ? color
                  : Theme.of(context).colorScheme.outlineVariant,
              width: active ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: .3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  if (calm) ...[
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        context.l10n.text('ΗΡΕΜΟ', 'CALM'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  Icon(
                    active ? Icons.check_circle : Icons.circle_outlined,
                    size: 21,
                    color: active
                        ? color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(
                detail,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveThemePreview extends StatelessWidget {
  const _LiveThemePreview({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: .2),
            colors.surfaceContainer,
          ],
        ),
        border: Border.all(color: colors.primary.withValues(alpha: .45)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.palette_outlined, color: colors.onPrimary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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
