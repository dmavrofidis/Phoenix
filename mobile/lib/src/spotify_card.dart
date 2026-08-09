import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      ? store.spotifyUrl
      : store.workoutPlaylistFor(templateId!);

  bool get _hasLink => _url.isNotEmpty;

  Future<void> _open(
    BuildContext context,
    String url, {
    bool external = true,
  }) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: external
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Δεν ήταν δυνατό να ανοίξει το Spotify.')),
      );
    }
  }

  Future<void> _configure(BuildContext context) async {
    final controller = TextEditingController(text: _url);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Σύνδεση Spotify'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Επικόλλησε σύνδεσμο playlist, album ή track από το Spotify.',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Spotify URL',
                  hintText: 'https://open.spotify.com/playlist/…',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => Navigator.of(context).pop(value),
              ),
              const SizedBox(height: 10),
              Text(
                'Το Phoenix αποθηκεύει μόνο τον σύνδεσμο στη συσκευή.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ακύρωση'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Σύνδεση'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !context.mounted) return;
    try {
      if (templateId == null) {
        await store.setSpotifyUrl(value);
      } else {
        await store.setWorkoutPlaylist(templateId!, value);
      }
    } on FormatException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withValues(alpha: .14),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.music_note, color: Color(0xFF1DB954)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasLink ? 'SPOTIFY ΣΥΝΔΕΔΕΜΕΝΟ' : 'SPOTIFY',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _hasLink
                        ? _linkType(_url)
                        : 'Σύνδεσε μουσική για την προπόνησή σου.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .52),
                    ),
                  ),
                ],
              ),
            ),
            if (_hasLink) ...[
              IconButton.filled(
                tooltip: 'Άνοιγμα στο Spotify',
                onPressed: () => _open(context, _url),
                icon: const Icon(Icons.play_arrow),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'change') _configure(context);
                  if (value == 'remove') {
                    if (templateId == null) {
                      store.clearSpotifyUrl();
                    } else {
                      store.clearWorkoutPlaylist(templateId!);
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'change', child: Text('Αλλαγή')),
                  PopupMenuItem(value: 'remove', child: Text('Αποσύνδεση')),
                ],
              ),
            ] else ...[
              TextButton(
                onPressed: () => _open(
                  context,
                  'https://open.spotify.com/search/workout',
                  external: false,
                ),
                child: const Text('Εύρεση'),
              ),
              FilledButton(
                onPressed: () => _configure(context),
                child: const Text('Σύνδεση'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _linkType(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.pathSegments.isEmpty) return 'Spotify';
  return switch (uri.pathSegments.first) {
    'playlist' => 'Playlist προπόνησης',
    'album' => 'Album',
    'track' => 'Track',
    _ => 'Spotify',
  };
}
