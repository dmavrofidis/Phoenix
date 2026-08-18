import 'package:flutter/material.dart';

import 'phoenix_l10n.dart';

class EquipmentQuickChoices extends StatelessWidget {
  const EquipmentQuickChoices({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text(
              'Διάλεξε όσα έχεις. Μπορείς να τα συνδυάσεις.',
              'Choose everything you have. You can combine options.',
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in _options)
                FilterChip(
                  key: ValueKey('equipment-${option.id}'),
                  selected: option.matches(controller.text),
                  avatar: Icon(option.icon, size: 18),
                  label: Text(
                    context.l10n.text(option.greekLabel, option.englishLabel),
                  ),
                  onSelected: (_) => _toggle(context, option),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggle(BuildContext context, _EquipmentOption option) {
    final entries = controller.text
        .split(RegExp(r'[,;]'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    final selected = option.matches(controller.text);

    if (option.exclusive) {
      entries
        ..clear()
        ..addAll(
          selected
              ? const []
              : [context.l10n.text(option.greekLabel, option.englishLabel)],
        );
    } else {
      entries.removeWhere(
        (entry) =>
            option.matches(entry) ||
            _options.any(
              (candidate) => candidate.exclusive && candidate.matches(entry),
            ),
      );
      if (!selected) {
        entries.add(context.l10n.text(option.greekLabel, option.englishLabel));
      }
    }

    final text = entries.join(', ');
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    onChanged?.call();
  }
}

class _EquipmentOption {
  const _EquipmentOption({
    required this.id,
    required this.greekLabel,
    required this.englishLabel,
    required this.icon,
    required this.aliases,
    this.exclusive = false,
  });

  final String id;
  final String greekLabel;
  final String englishLabel;
  final IconData icon;
  final List<String> aliases;
  final bool exclusive;

  bool matches(String value) {
    final normalized = value.toLowerCase();
    return aliases.any(normalized.contains);
  }
}

const _options = [
  _EquipmentOption(
    id: 'none',
    greekLabel: 'Χωρίς εξοπλισμό',
    englishLabel: 'No equipment',
    icon: Icons.accessibility_new,
    aliases: ['χωρίς εξοπλισμό', 'no equipment'],
    exclusive: true,
  ),
  _EquipmentOption(
    id: 'dumbbells',
    greekLabel: 'Αλτήρες / βαράκια',
    englishLabel: 'Dumbbells',
    icon: Icons.fitness_center,
    aliases: ['αλτήρ', 'βαράκ', 'dumbbell'],
  ),
  _EquipmentOption(
    id: 'bench',
    greekLabel: 'Πάγκος',
    englishLabel: 'Bench',
    icon: Icons.weekend_outlined,
    aliases: ['πάγκο', 'πάγκος', 'bench'],
  ),
  _EquipmentOption(
    id: 'treadmill',
    greekLabel: 'Απλός διάδρομος',
    englishLabel: 'Basic treadmill',
    icon: Icons.directions_walk,
    aliases: ['διάδρομ', 'treadmill'],
  ),
  _EquipmentOption(
    id: 'bands',
    greekLabel: 'Λάστιχα',
    englishLabel: 'Bands',
    icon: Icons.linear_scale,
    aliases: ['λάστιχ', 'band'],
  ),
  _EquipmentOption(
    id: 'pull-up-bar',
    greekLabel: 'Μονόζυγο',
    englishLabel: 'Pull-up bar',
    icon: Icons.horizontal_rule,
    aliases: ['μονόζυγ', 'pull-up bar'],
  ),
  _EquipmentOption(
    id: 'full-gym',
    greekLabel: 'Πλήρες γυμναστήριο',
    englishLabel: 'Full gym',
    icon: Icons.apartment,
    aliases: ['πλήρες γυμναστήριο', 'full gym'],
    exclusive: true,
  ),
];
