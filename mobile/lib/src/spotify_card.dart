import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'music_link.dart';
import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class SpotifyCard extends StatelessWidget {
  const SpotifyCard({
    super.key,
    required this.store,
    this.compact = false,
    this.templateId,
  });

  final FitnessStore store;
  final bool compact;
  final String? templateId;

  String get _url => templateId == null
      ? store.musicUrl
      : store.workoutPlaylistFor(templateId!);

  bool get _hasLink => _url.isNotEmpty;

  Future<void> _open(
    BuildContext context,
    Uri uri, {
    required String serviceName,
  }) async {
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      if (opened || !context.mounted) return;
    } on PlatformException {
      if (!context.mounted) return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.text(
            'Δεν ήταν δυνατό να ανοίξει το $serviceName.',
            'Could not open $serviceName.',
          ),
        ),
      ),
    );
  }

  Future<void> _configure(
    BuildContext context, {
    MusicService? initialService,
  }) async {
    var service =
        initialService ?? MusicLink.serviceFor(_url) ?? MusicService.spotify;
    final controller = TextEditingController(text: _url);
    final result = await showDialog<_MusicSelection>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final serviceName = MusicLink.serviceName(service);
          return AlertDialog(
            title: Text(context.l10n.text('Σύνδεση μουσικής', 'Connect music')),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<MusicService>(
                      segments: const [
                        ButtonSegment(
                          value: MusicService.spotify,
                          icon: Icon(Icons.music_note),
                          label: Text('Spotify'),
                        ),
                        ButtonSegment(
                          value: MusicService.appleMusic,
                          icon: Icon(Icons.apple),
                          label: Text('Apple Music'),
                        ),
                      ],
                      selected: {service},
                      onSelectionChanged: (selection) {
                        final next = selection.first;
                        setDialogState(() {
                          service = next;
                          if (MusicLink.serviceFor(controller.text) != next) {
                            controller.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.text(
                        '1. Άνοιξε το $serviceName και βρες τη μουσική σου.\n'
                            '2. Πάτησε Κοινοποίηση → Αντιγραφή συνδέσμου.\n'
                            '3. Γύρνα εδώ και πάτησε Επικόλληση.',
                        '1. Open $serviceName and find your music.\n'
                            '2. Tap Share → Copy link.\n'
                            '3. Return here and tap Paste.',
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _open(
                            dialogContext,
                            MusicLink.searchUri(service),
                            serviceName: serviceName,
                          ),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(
                            context.l10n.text(
                              'Άνοιγμα $serviceName',
                              'Open $serviceName',
                            ),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          key: const ValueKey('paste-music-link'),
                          onPressed: () async {
                            final clipboard = await Clipboard.getData(
                              Clipboard.kTextPlain,
                            );
                            final text = clipboard?.text?.trim() ?? '';
                            if (text.isEmpty) {
                              if (!dialogContext.mounted) return;
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.text(
                                      'Δεν βρέθηκε αντιγραμμένος σύνδεσμος.',
                                      'No copied link was found.',
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }
                            controller.value = TextEditingValue(
                              text: text,
                              selection: TextSelection.collapsed(
                                offset: text.length,
                              ),
                            );
                            setDialogState(() {});
                          },
                          icon: const Icon(Icons.content_paste),
                          label: Text(context.l10n.text('Επικόλληση', 'Paste')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      key: const ValueKey('music-link-input'),
                      controller: controller,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: context.l10n.text(
                          'Σύνδεσμος μουσικής',
                          'Music link',
                        ),
                        hintText: service == MusicService.spotify
                            ? 'open.spotify.com/playlist/…'
                            : 'music.apple.com/…',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.text(
                        'Το Phoenix αποθηκεύει μόνο τον σύνδεσμο στη συσκευή σου.',
                        'Phoenix stores only the link on your device.',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.text('Ακύρωση', 'Cancel')),
              ),
              FilledButton(
                key: const ValueKey('save-music-link'),
                onPressed: () => Navigator.of(context).pop(
                  _MusicSelection(service: service, value: controller.text),
                ),
                child: Text(context.l10n.text('Αποθήκευση', 'Save')),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
    if (result == null || !context.mounted) return;

    try {
      final normalized = MusicLink.normalize(
        result.value,
        expectedService: result.service,
      );
      if (templateId == null) {
        await store.setMusicUrl(normalized);
      } else {
        await store.setWorkoutPlaylist(templateId!, normalized);
      }
    } on FormatException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _remove() async {
    if (templateId == null) {
      await store.clearSpotifyUrl();
    } else {
      await store.clearWorkoutPlaylist(templateId!);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final service = MusicLink.serviceFor(_url);
      final color = service == MusicService.appleMusic
          ? const Color(0xFFFA2D48)
          : const Color(0xFF1DB954);
      final serviceName = service == null
          ? null
          : MusicLink.serviceName(service);
      return Card(
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.music_note, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasLink
                              ? '$serviceName ${context.l10n.text('ΣΥΝΔΕΔΕΜΕΝΟ', 'CONNECTED')}'
                              : context.l10n.text(
                                  'ΜΟΥΣΙΚΗ ΠΡΟΠΟΝΗΣΗΣ',
                                  'WORKOUT MUSIC',
                                ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _hasLink
                              ? _linkType(context, _url)
                              : context.l10n.text(
                                  'Άνοιξε την εφαρμογή και επικόλλησε τον σύνδεσμο με ένα πάτημα.',
                                  'Open the app and paste its link with one tap.',
                                ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_hasLink)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _open(
                          context,
                          Uri.parse(_url),
                          serviceName: serviceName ?? 'music',
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          context.l10n.text(
                            'Άνοιγμα $serviceName',
                            'Open $serviceName',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: context.l10n.text('Αλλαγή', 'Change'),
                      onPressed: () =>
                          _configure(context, initialService: service),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: context.l10n.text('Αποσύνδεση', 'Disconnect'),
                      onPressed: _remove,
                      icon: const Icon(Icons.link_off),
                    ),
                  ],
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      key: const ValueKey('connect-spotify'),
                      onPressed: () => _configure(
                        context,
                        initialService: MusicService.spotify,
                      ),
                      icon: const Icon(Icons.music_note),
                      label: const Text('Spotify'),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('connect-apple-music'),
                      onPressed: () => _configure(
                        context,
                        initialService: MusicService.appleMusic,
                      ),
                      icon: const Icon(Icons.apple),
                      label: const Text('Apple Music'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _MusicSelection {
  const _MusicSelection({required this.service, required this.value});

  final MusicService service;
  final String value;
}

String _linkType(BuildContext context, String url) {
  final uri = Uri.tryParse(url);
  final type = uri?.pathSegments.firstWhere(
    const {'playlist', 'album', 'track', 'song', 'station'}.contains,
    orElse: () => '',
  );
  return switch (type) {
    'playlist' => context.l10n.text('Playlist προπόνησης', 'Workout playlist'),
    'album' => 'Album',
    'track' || 'song' => context.l10n.text('Τραγούδι', 'Song'),
    'station' => context.l10n.text('Σταθμός', 'Station'),
    _ => context.l10n.text('Μουσική προπόνησης', 'Workout music'),
  };
}
