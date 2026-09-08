import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'coaching_report_engine.dart';
import 'encrypted_sync_engine.dart';
import 'local_file_bridge.dart';
import 'media_portability_engine.dart';
import 'models/fitness_models.dart';
import 'secure_backup_engine.dart';
import 'state/fitness_store.dart';
import 'workout_notification_sync.dart';

class MediaPortabilityPage extends StatelessWidget {
  const MediaPortabilityPage({
    super.key,
    required this.store,
    this.initialTab = 0,
  });

  final FitnessStore store;
  final int initialTab;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    initialIndex: initialTab.clamp(0, 3),
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Αρχεία, μουσική & μεταφορά'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'ΚΟΙΝΟΠΟΙΗΣΗ', icon: Icon(Icons.ios_share)),
            Tab(text: 'ΦΩΤΟΓΡΑΦΙΕΣ', icon: Icon(Icons.photo_library_outlined)),
            Tab(text: 'ΜΟΥΣΙΚΗ', icon: Icon(Icons.play_circle_outline)),
            Tab(text: 'ΜΕΤΑΦΟΡΑ', icon: Icon(Icons.qr_code_2)),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _ShareTab(store: store),
          _PhotoVaultTab(store: store),
          _MediaTab(store: store),
          _TransferTab(store: store),
        ],
      ),
    ),
  );
}

class _ShareTab extends StatefulWidget {
  const _ShareTab({required this.store});

  final FitnessStore store;

  @override
  State<_ShareTab> createState() => _ShareTabState();
}

class _ShareTabState extends State<_ShareTab> {
  String? _templateId;

  WorkoutTemplate get _template {
    final templates = widget.store.data.templates;
    final id = _templateId ?? templates.first.id;
    return templates.firstWhere(
      (item) => item.id == id,
      orElse: () => templates.first,
    );
  }

  Future<void> _copyCard(WorkoutShareSummary summary) async {
    await Clipboard.setData(ClipboardData(text: summary.shareText));
    if (!mounted) return;
    _message('Η local share card αντιγράφηκε.');
  }

  Future<void> _coachingPdf() async {
    final bytes = await CoachingReportEngine.buildCoachingReport(
      widget.store.data,
    );
    final saved = await saveLocalBytes(
      bytes: bytes,
      filename: 'phoenix-coaching-report.pdf',
      mimeType: 'application/pdf',
    );
    if (!saved && mounted) {
      _message('Η αποθήκευση ακυρώθηκε ή δεν υποστηρίζεται στη συσκευή.');
    }
  }

  Future<void> _workoutSheet() async {
    final bytes = await CoachingReportEngine.buildWorkoutSheet(_template);
    final saved = await saveLocalBytes(
      bytes: bytes,
      filename: 'phoenix-${_safeName(_template.name)}-sheet.pdf',
      mimeType: 'application/pdf',
    );
    if (!saved && mounted) {
      _message('Η αποθήκευση ακυρώθηκε ή δεν υποστηρίζεται στη συσκευή.');
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final templates = widget.store.data.templates;
    if (templates.isEmpty) {
      return const Center(child: Text('Δεν υπάρχουν προγράμματα.'));
    }
    final summary = MediaPortabilityEngine.shareSummary(
      widget.store.data,
      _template,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        Text(
          'LOCAL WORKOUT SHARE CARD',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        const Text(
          'Δημιουργείται στη συσκευή σου και δεν ανεβάζει δεδομένα σε server.',
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _template.id,
          decoration: const InputDecoration(
            labelText: 'Πρόγραμμα',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final template in templates)
              DropdownMenuItem(value: template.id, child: Text(template.name)),
          ],
          onChanged: (value) => setState(() => _templateId = value),
        ),
        const SizedBox(height: 14),
        _ShareCard(summary: summary),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _copyCard(summary),
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('COPY SHARE CARD'),
        ),
        const SizedBox(height: 24),
        Text(
          'REPORTS & PRINT',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text(
                  'Coaching PDF report',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  'Snapshot, workload guardrails, recent sessions και actions.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _coachingPdf,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: const Text(
                  'Printable workout sheet',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(_template.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: _workoutSheet,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.summary});

  final WorkoutShareSummary summary;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF101B28), Color(0xFF070707)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Theme.of(context).colorScheme.primary),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
          blurRadius: 28,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHOENIX // ${summary.subtitle}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          summary.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final stat in summary.stats)
              Chip(visualDensity: VisualDensity.compact, label: Text(stat)),
          ],
        ),
        const Divider(height: 26),
        for (final line in summary.exerciseLines)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(line)),
        const SizedBox(height: 9),
        const Text(
          'BUILT LOCALLY. TRAINED DELIBERATELY.',
          style: TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}

class _PhotoVaultTab extends StatefulWidget {
  const _PhotoVaultTab({required this.store});

  final FitnessStore store;

  @override
  State<_PhotoVaultTab> createState() => _PhotoVaultTabState();
}

class _PhotoVaultTabState extends State<_PhotoVaultTab> {
  Future<void> _addPhoto() async {
    try {
      final file = await pickLocalFile(
        extensions: const ['jpg', 'jpeg', 'png', 'webp'],
      );
      final raw = file?.bytes;
      if (file == null || raw == null) return;
      final decoded = img.decodeImage(raw);
      if (decoded == null) {
        throw const FormatException('Η εικόνα δεν μπορεί να διαβαστεί.');
      }
      final resized = decoded.width > 960
          ? img.copyResize(decoded, width: 960)
          : decoded;
      final encoded = Uint8List.fromList(img.encodeJpg(resized, quality: 78));
      if (!mounted) return;
      final details = await _photoDetails();
      if (details == null) return;
      await widget.store.saveProgressPhoto(
        encodedBytes: base64Encode(encoded),
        mimeType: 'image/jpeg',
        note: details.$1,
        weightKilograms: details.$2,
      );
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<(String, double?)?> _photoDetails() async {
    final note = TextEditingController();
    final weight = TextEditingController(
      text: widget.store.currentWeightKilograms.toStringAsFixed(1),
    );
    final result = await showDialog<(String, double?)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PRIVATE PROGRESS PHOTO'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: note,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Σημείωση'),
            ),
            TextField(
              controller: weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Βάρος',
                suffixText: 'kg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ΑΚΥΡΟ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (
              note.text.trim(),
              double.tryParse(weight.text.replaceAll(',', '.')),
            )),
            child: const Text('ΑΠΟΘΗΚΕΥΣΗ'),
          ),
        ],
      ),
    );
    note.dispose();
    weight.dispose();
    return result;
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final locked = widget.store.hasVaultPin && !widget.store.vaultUnlocked;
      final photos = widget.store.progressPhotos;
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [
          Text(
            'PRIVATE PROGRESS-PHOTO VAULT',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            locked
                ? 'Το vault είναι κλειδωμένο. Ξεκλείδωσέ το από το Control Center.'
                : 'Οι εικόνες συμπιέζονται και αποθηκεύονται μόνο τοπικά. Μέγιστο 12.',
          ),
          if (!widget.store.hasVaultPin) ...[
            const SizedBox(height: 10),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline, color: Color(0xFFFFB74D)),
                title: Text('Συνιστάται PIN στο Data Vault'),
                subtitle: Text(
                  'Η local αποθήκευση είναι ιδιωτική, αλλά το PIN προσθέτει κλείδωμα μέσα στην εφαρμογή.',
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: locked ? null : _addPhoto,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('ADD LOCAL PHOTO'),
          ),
          const SizedBox(height: 18),
          if (photos.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.hide_image_outlined),
                title: Text('Δεν υπάρχουν φωτογραφίες'),
                subtitle: Text('Η πρώτη φωτογραφία θα εμφανιστεί εδώ.'),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .82,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.memory(
                          base64Decode(photo.encodedBytes),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 4, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                photo.note.isEmpty
                                    ? _shortDate(photo.recordedAt)
                                    : photo.note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Διαγραφή',
                              onPressed: () =>
                                  widget.store.removeProgressPhoto(photo.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    },
  );
}

class _MediaTab extends StatefulWidget {
  const _MediaTab({required this.store});

  final FitnessStore store;

  @override
  State<_MediaTab> createState() => _MediaTabState();
}

class _MediaTabState extends State<_MediaTab> {
  String? _playlistTemplateId;
  String? _videoExercise;
  late final TextEditingController _playlist;
  late final TextEditingController _video;

  @override
  void initState() {
    super.initState();
    _playlistTemplateId = widget.store.data.templates.firstOrNull?.id;
    _videoExercise = _exercises.firstOrNull;
    _playlist = TextEditingController(
      text: _playlistTemplateId == null
          ? ''
          : widget.store.workoutPlaylistFor(_playlistTemplateId!),
    );
    _video = TextEditingController(
      text: _videoExercise == null
          ? ''
          : widget.store.exerciseVideoFor(_videoExercise!),
    );
  }

  List<String> get _exercises => {
    for (final template in widget.store.data.templates) ...template.exercises,
  }.toList()..sort();

  @override
  void dispose() {
    _playlist.dispose();
    _video.dispose();
    super.dispose();
  }

  Future<void> _spotifySetup() async {
    final clientId = TextEditingController(
      text: widget.store.spotifyAuth.clientId,
    );
    final redirect = TextEditingController(
      text: widget.store.spotifyAuth.redirectUri.isEmpty
          ? Uri.base.replace(query: '').toString()
          : widget.store.spotifyAuth.redirectUri,
    );
    final configured = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SPOTIFY OAUTH + PKCE'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Βάλε το Client ID από το Spotify Developer Dashboard. Δεν αποθηκεύεται client secret.',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: clientId,
                decoration: const InputDecoration(
                  labelText: 'Spotify Client ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: redirect,
                decoration: const InputDecoration(
                  labelText: 'Redirect URI',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ΑΚΥΡΟ'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final pkce = MediaPortabilityEngine.createSpotifyPkce();
                await widget.store.configureSpotifyOAuth(
                  clientId: clientId.text,
                  redirectUri: redirect.text,
                  pkceVerifier: pkce.verifier,
                  pkceChallenge: pkce.challenge,
                );
                if (context.mounted) Navigator.pop(context, true);
              } on FormatException catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error.message)));
                }
              }
            },
            child: const Text('ΑΠΟΘΗΚΕΥΣΗ'),
          ),
        ],
      ),
    );
    clientId.dispose();
    redirect.dispose();
    if (configured == true && mounted) setState(() {});
  }

  Future<void> _authorizeSpotify() async {
    final uri = MediaPortabilityEngine.spotifyAuthorizeUri(
      widget.store.spotifyAuth,
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      _message('Δεν άνοιξε το Spotify authorization.');
    }
  }

  Future<void> _savePlaylist() async {
    final id = _playlistTemplateId;
    if (id == null) return;
    try {
      await widget.store.setWorkoutPlaylist(id, _playlist.text);
      _message('Η playlist συνδέθηκε με το πρόγραμμα.');
    } on FormatException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _pastePlaylist() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final value = clipboard?.text?.trim() ?? '';
    if (value.isEmpty) {
      _message('Δεν βρέθηκε αντιγραμμένος σύνδεσμος.');
      return;
    }
    setState(() => _playlist.text = value);
  }

  Future<void> _saveVideo() async {
    final exercise = _videoExercise;
    if (exercise == null) return;
    try {
      await widget.store.setExerciseVideo(exercise, _video.text);
      _message('Το video link αποθηκεύτηκε.');
    } on FormatException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _open(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) _message('Ο σύνδεσμος δεν άνοιξε.');
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final preferences = widget.store.preferences;
      final auth = widget.store.spotifyAuth;
      final templates = widget.store.data.templates;
      final exercises = _exercises;
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [
          Text(
            'CONFIGURABLE AUDIO CUES',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Audio feedback',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: const Text('Cue σε ολοκλήρωση και χρονόμετρα.'),
                    value: preferences.audioCues,
                    onChanged: (value) =>
                        widget.store.updatePreferences(audioCues: value),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'minimal', label: Text('MINIMAL')),
                      ButtonSegment(value: 'coach', label: Text('COACH')),
                      ButtonSegment(value: 'silent', label: Text('SILENT')),
                    ],
                    selected: {preferences.audioCueStyle},
                    onSelectionChanged: (value) => widget.store
                        .updatePreferences(audioCueStyle: value.first),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Text('Countdown warning')),
                      Text(
                        '${preferences.countdownCueSeconds}s',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Slider(
                    min: 0,
                    max: 10,
                    divisions: 10,
                    value: preferences.countdownCueSeconds.toDouble(),
                    onChanged: (value) => widget.store.updatePreferences(
                      countdownCueSeconds: value.round(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'SPOTIFY OAUTH CONFIGURATION',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    auth.isConfigured
                        ? Icons.verified_user_outlined
                        : Icons.key_outlined,
                    color: auth.isConfigured
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFFFFB74D),
                  ),
                  title: Text(
                    auth.isConfigured
                        ? 'PKCE configuration ready'
                        : 'Spotify Developer setup required',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    auth.isConfigured
                        ? 'Client ID και redirect URI αποθηκεύτηκαν τοπικά.'
                        : 'Χωρίς client secret • OAuth Authorization Code + PKCE.',
                  ),
                  trailing: TextButton(
                    onPressed: _spotifySetup,
                    child: Text(auth.isConfigured ? 'EDIT' : 'SET UP'),
                  ),
                ),
                if (auth.isConfigured) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: const Text('Open Spotify authorization'),
                    subtitle: const Text(
                      'Θα ανοίξει το επίσημο accounts.spotify.com.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _authorizeSpotify,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'PLAYLIST PER WORKOUT',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _playlistTemplateId,
            decoration: const InputDecoration(
              labelText: 'Workout',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final template in templates)
                DropdownMenuItem(
                  value: template.id,
                  child: Text(template.name),
                ),
            ],
            onChanged: (value) {
              setState(() {
                _playlistTemplateId = value;
                _playlist.text = value == null
                    ? ''
                    : widget.store.workoutPlaylistFor(value);
              });
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _playlist,
            decoration: InputDecoration(
              labelText: 'Spotify ή Apple Music σύνδεσμος',
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Επικόλληση',
                    onPressed: _pastePlaylist,
                    icon: const Icon(Icons.content_paste),
                  ),
                  IconButton(
                    tooltip: 'Άνοιγμα',
                    onPressed: _playlist.text.trim().isEmpty
                        ? null
                        : () => _open(_playlist.text.trim()),
                    icon: const Icon(Icons.open_in_new),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          FilledButton.icon(
            onPressed: _savePlaylist,
            icon: const Icon(Icons.library_music_outlined),
            label: const Text('SAVE WORKOUT PLAYLIST'),
          ),
          const SizedBox(height: 22),
          Text(
            'EXERCISE VIDEO-LINK LIBRARY',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _videoExercise,
            decoration: const InputDecoration(
              labelText: 'Exercise',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final exercise in exercises)
                DropdownMenuItem(value: exercise, child: Text(exercise)),
            ],
            onChanged: (value) {
              setState(() {
                _videoExercise = value;
                _video.text = value == null
                    ? ''
                    : widget.store.exerciseVideoFor(value);
              });
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _video,
            decoration: InputDecoration(
              labelText: 'HTTPS video URL',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Άνοιγμα',
                onPressed: _video.text.trim().isEmpty
                    ? null
                    : () => _open(_video.text.trim()),
                icon: const Icon(Icons.play_arrow),
              ),
            ),
          ),
          const SizedBox(height: 9),
          FilledButton.icon(
            onPressed: _saveVideo,
            icon: const Icon(Icons.video_library_outlined),
            label: const Text('SAVE EXERCISE VIDEO'),
          ),
        ],
      );
    },
  );
}

class _TransferTab extends StatefulWidget {
  const _TransferTab({required this.store});

  final FitnessStore store;

  @override
  State<_TransferTab> createState() => _TransferTabState();
}

class _TransferTabState extends State<_TransferTab> {
  int _frameIndex = 0;
  final _framesInput = TextEditingController();

  List<String> get _frames =>
      MediaPortabilityEngine.qrFrames(widget.store.exportBackup());

  @override
  void dispose() {
    _framesInput.dispose();
    super.dispose();
  }

  Future<void> _copyFrame() async {
    await Clipboard.setData(ClipboardData(text: _frames[_frameIndex]));
    if (mounted) _message('Αντιγράφηκε το τμήμα ${_frameIndex + 1} του QR.');
  }

  Future<void> _exportBackupFile() async {
    final now = DateTime.now();
    final stamp =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final saved = await saveLocalBytes(
      bytes: Uint8List.fromList(utf8.encode(widget.store.exportBackup())),
      filename: 'phoenix-backup-$stamp.json',
      mimeType: 'application/json',
    );
    if (!mounted) return;
    _message(
      saved
          ? 'Το πλήρες local backup εξήχθη με ασφάλεια.'
          : 'Η εξαγωγή ακυρώθηκε ή δεν υποστηρίζεται στη συσκευή.',
    );
  }

  Future<void> _importBackupFile() async {
    try {
      final file = await pickLocalFile(
        extensions: const <String>['json'],
        maxBytes: 15 * 1024 * 1024,
      );
      if (file == null) return;
      final backup = utf8.decode(file.bytes, allowMalformed: false);
      await _confirmAndRestore(backup, source: 'Το backup αρχείου');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<String?> _requestExportPassword({
    required bool confirm,
    String purpose = 'BACKUP',
  }) async {
    final password = TextEditingController();
    final confirmation = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            confirm
                ? 'Προστάτευσε το αρχείο με κωδικό'
                : 'Άνοιξε το προστατευμένο αρχείο',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: password,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Κωδικός (τουλάχιστον 10 χαρακτήρες)',
                ),
              ),
              if (confirm)
                TextField(
                  controller: confirmation,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Γράψε ξανά τον κωδικό',
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ΑΚΥΡΟ'),
            ),
            FilledButton(
              onPressed: () {
                if (password.text.length < 10 ||
                    (confirm && password.text != confirmation.text)) {
                  return;
                }
                Navigator.pop(context, password.text);
              },
              child: Text(confirm ? 'ΠΡΟΣΤΑΣΙΑ' : 'ΑΝΟΙΓΜΑ'),
            ),
          ],
        ),
      );
    } finally {
      password.dispose();
      confirmation.dispose();
    }
  }

  Future<void> _exportEncryptedBackup() async {
    final password = await _requestExportPassword(confirm: true);
    if (password == null) return;
    try {
      final envelope = await SecureBackupEngine.encrypt(
        clearText: widget.store.exportBackup(),
        password: password,
      );
      final saved = await saveLocalBytes(
        bytes: Uint8List.fromList(utf8.encode(envelope)),
        filename: 'phoenix-encrypted-backup.phx',
        mimeType: 'application/octet-stream',
      );
      if (mounted) {
        _message(
          saved
              ? 'Το προστατευμένο αντίγραφο ασφαλείας αποθηκεύτηκε.'
              : 'Η εξαγωγή ακυρώθηκε ή δεν υποστηρίζεται.',
        );
      }
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _importEncryptedBackup() async {
    final file = await pickLocalFile(
      extensions: const <String>['phx'],
      maxBytes: 20 * 1024 * 1024,
    );
    if (file == null || !mounted) return;
    final password = await _requestExportPassword(confirm: false);
    if (password == null) return;
    try {
      final backup = await SecureBackupEngine.decrypt(
        envelope: utf8.decode(file.bytes, allowMalformed: false),
        password: password,
      );
      await _confirmAndRestore(
        backup,
        source: 'Το προστατευμένο αντίγραφο ασφαλείας',
      );
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _exportEncryptedSync() async {
    final password = await _requestExportPassword(
      confirm: true,
      purpose: 'SYNC PACKAGE',
    );
    if (password == null) return;
    try {
      final now = DateTime.now();
      final envelope = await EncryptedSyncEngine.create(
        data: widget.store.data,
        password: password,
        deviceId: 'phoenix-local-device',
        revision: now.microsecondsSinceEpoch,
        createdAt: now,
      );
      final saved = await saveLocalBytes(
        bytes: Uint8List.fromList(utf8.encode(envelope)),
        filename: 'phoenix-device-sync.phxsync',
        mimeType: 'application/octet-stream',
      );
      if (mounted) {
        _message(
          saved
              ? 'Το προστατευμένο αρχείο μεταφοράς αποθηκεύτηκε. Μπορείς να το στείλεις με καλώδιο ή ιδιωτικό φάκελο.'
              : 'Η εξαγωγή ακυρώθηκε ή δεν υποστηρίζεται.',
        );
      }
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _importEncryptedSync() async {
    final file = await pickLocalFile(
      extensions: const <String>['phxsync'],
      maxBytes: EncryptedSyncEngine.maximumEnvelopeBytes,
    );
    if (file == null || !mounted) return;
    final password = await _requestExportPassword(
      confirm: false,
      purpose: 'SYNC PACKAGE',
    );
    if (password == null) return;
    try {
      final incoming = await EncryptedSyncEngine.open(
        envelope: utf8.decode(file.bytes, allowMalformed: false),
        password: password,
      );
      final preview = EncryptedSyncEngine.preview(
        local: widget.store.data,
        incoming: incoming,
      );
      if (!mounted) return;
      if (preview.alreadyInSync) {
        _message('Οι δύο συσκευές έχουν ήδη τα ίδια επαληθευμένα δεδομένα.');
        return;
      }
      final resolution = await _chooseSyncResolution(preview, incoming);
      if (resolution == null || resolution == SyncResolution.keepLocal) {
        if (resolution == SyncResolution.keepLocal && mounted) {
          _message('Τα δεδομένα αυτής της συσκευής έμειναν όπως ήταν.');
        }
        return;
      }
      final resolved = EncryptedSyncEngine.resolve(
        local: widget.store.data,
        incoming: incoming,
        resolution: resolution,
      );
      await widget.store.applyApprovedSyncData(resolved);
      await syncPhoenixWorkoutNotifications(widget.store);
      if (mounted) {
        _message(
          resolution == SyncResolution.mergeSafely
              ? 'Τα δεδομένα ενώθηκαν με ασφάλεια. Μπορείς να αναιρέσεις την αλλαγή.'
              : 'Τα δεδομένα της άλλης συσκευής εφαρμόστηκαν. Μπορείς να αναιρέσεις την αλλαγή.',
        );
      }
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<SyncResolution?> _chooseSyncResolution(
    SyncConflictPreview preview,
    EncryptedSyncPackage incoming,
  ) => showDialog<SyncResolution>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Έλεγχος πριν από τη μεταφορά'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Revision ${incoming.revision} • ${incoming.createdAt.toLocal()}',
              ),
              const SizedBox(height: 8),
              Text(
                preview.baseMatchesLocal
                    ? 'Το αρχείο προέρχεται από τα ίδια αρχικά δεδομένα.'
                    : 'Το αρχείο δημιουργήθηκε από διαφορετική κατάσταση δεδομένων.',
              ),
              const SizedBox(height: 12),
              Text(
                'Ενότητες που άλλαξαν: ${preview.changedSections.join(', ')}',
              ),
              if (preview.conflicts.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'ΔΙΑΦΟΡΕΣ ΠΟΥ ΧΡΕΙΑΖΟΝΤΑΙ ΠΡΟΣΟΧΗ',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                for (final conflict in preview.conflicts) Text('• $conflict'),
              ],
              const SizedBox(height: 12),
              const Text(
                'Τίποτα δεν αλλάζει πριν επιλέξεις. Η ασφαλής ένωση προσθέτει μόνο τις νέες εγγραφές και κρατά τα τοπικά δεδομένα όπου υπάρχει διαφορά.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ΑΚΥΡΟ'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, SyncResolution.keepLocal),
          child: const Text('ΚΡΑΤΗΣΕ ΤΑ ΤΟΠΙΚΑ'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context, SyncResolution.mergeSafely),
          child: const Text('ΑΣΦΑΛΗΣ ΕΝΩΣΗ'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, SyncResolution.useIncoming),
          child: const Text('ΧΡΗΣΗ ΤΟΥ ΑΡΧΕΙΟΥ'),
        ),
      ],
    ),
  );

  Future<void> _confirmAndRestore(
    String backup, {
    required String source,
  }) async {
    if (!mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Επαναφορά αντιγράφου ασφαλείας;'),
        content: const Text(
          'Τα τρέχοντα δεδομένα θα αντικατασταθούν. Αποθήκευσε πρώτα ένα δικό σου αντίγραφο ασφαλείας.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ΑΚΥΡΟ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ΕΠΑΝΑΦΟΡΑ'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    await widget.store.restoreBackup(backup);
    await syncPhoenixWorkoutNotifications(widget.store);
    if (mounted) _message('$source επαναφέρθηκε.');
  }

  Future<void> _restoreFrames() async {
    try {
      final backup = MediaPortabilityEngine.assembleQrFrames(
        const LineSplitter().convert(_framesInput.text),
      );
      await _confirmAndRestore(backup, source: 'Το QR backup');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _importWearable() async {
    try {
      final file = await pickLocalFile(extensions: const ['csv', 'json']);
      if (file?.bytes == null) return;
      final text = utf8.decode(file!.bytes, allowMalformed: false);
      final summaries = MediaPortabilityEngine.parseWearable(
        text,
        source: file.name,
      );
      await widget.store.saveWearableSummaries(summaries);
      if (mounted) _message('Εισήχθησαν ${summaries.length} wearable ημέρες.');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final frames = _frames;
      if (_frameIndex >= frames.length) _frameIndex = 0;
      final wearable = widget.store.wearableSummaries;
      return ListView(
        key: const ValueKey('media-transfer-scroll'),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [
          Text(
            'Μεταφορά με αρχείο',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'Μετέφερε ολόκληρο το Phoenix σου σε άλλη συσκευή, χωρίς λογαριασμό ή cloud.',
          ),
          const SizedBox(height: 10),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                '1. Δημιούργησε το προστατευμένο αρχείο.\n'
                '2. Στείλε το στο άλλο κινητό ή laptop.\n'
                '3. Άνοιξέ το εκεί με τον ίδιο κωδικό.',
                style: TextStyle(height: 1.55, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const ValueKey('export-encrypted-phoenix'),
            onPressed: _exportEncryptedBackup,
            icon: const Icon(Icons.enhanced_encryption_outlined),
            label: const Text('Δημιουργία προστατευμένου αρχείου'),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            key: const ValueKey('import-encrypted-phoenix'),
            onPressed: _importEncryptedBackup,
            icon: const Icon(Icons.lock_open_outlined),
            label: const Text('Άνοιγμα προστατευμένου αρχείου'),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _exportBackupFile,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Αποθήκευση αντιγράφου ασφαλείας'),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _importBackupFile,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Επαναφορά από αρχείο'),
          ),
          const SizedBox(height: 24),
          Text(
            'Μεταφορά με QR',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            'Το αντίγραφο χωρίζεται σε ${frames.length} τμήματα QR. Σκάναρέ τα όλα στη δεύτερη συσκευή.',
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: QrImageView(
                data: frames[_frameIndex],
                size: 250,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'ΤΜΗΜΑ ${_frameIndex + 1} ΑΠΟ ${frames.length}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Slider(
            min: 0,
            max: (frames.length - 1).toDouble(),
            divisions: frames.length > 1 ? frames.length - 1 : null,
            value: _frameIndex.toDouble(),
            onChanged: frames.length == 1
                ? null
                : (value) => setState(() => _frameIndex = value.round()),
          ),
          OutlinedButton.icon(
            onPressed: _copyFrame,
            icon: const Icon(Icons.copy),
            label: const Text('Αντιγραφή αυτού του τμήματος'),
          ),
          const SizedBox(height: 14),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text(
              'Επαναφορά σαρωμένων τμημάτων',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text(
              'Ένα PHX1 frame ανά γραμμή, με οποιαδήποτε σειρά.',
            ),
            children: [
              TextField(
                controller: _framesInput,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'PHX1:1:…\nPHX1:2:…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _restoreFrames,
                icon: const Icon(Icons.restore),
                label: const Text('Έλεγχος και επαναφορά'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Card(
            child: ListTile(
              leading: Icon(Icons.sync_lock_outlined),
              title: Text(
                'Ασφαλής ένωση δεδομένων δύο συσκευών',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                'Δημιουργεί ένα προστατευμένο αρχείο και σου δείχνει τις διαφορές πριν αλλάξει οτιδήποτε. Το Phoenix δεν επικοινωνεί με κανέναν πάροχο.',
              ),
            ),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            key: const ValueKey('export-encrypted-sync'),
            onPressed: _exportEncryptedSync,
            icon: const Icon(Icons.sync_lock_outlined),
            label: const Text('Δημιουργία αρχείου μεταφοράς'),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            key: const ValueKey('import-encrypted-sync'),
            onPressed: _importEncryptedSync,
            icon: const Icon(Icons.rule_folder_outlined),
            label: const Text('Άνοιγμα και έλεγχος αρχείου'),
          ),
          const SizedBox(height: 22),
          Text(
            'STANDARD WEARABLE IMPORT',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.watch_outlined),
              title: const Text(
                'Import CSV or JSON',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'date, steps, restingHeartRate/rhr, sleepMinutes/sleepHours',
              ),
              trailing: const Icon(Icons.upload_file),
              onTap: _importWearable,
            ),
          ),
          if (wearable.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final item in wearable.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.monitor_heart_outlined),
                title: Text('${_shortDate(item.day)} • ${item.steps} steps'),
                subtitle: Text(
                  'RHR ${item.restingHeartRate == 0 ? '—' : item.restingHeartRate} • '
                  'Sleep ${(item.sleepMinutes / 60).toStringAsFixed(1)}h • ${item.source}',
                ),
              ),
          ],
        ],
      );
    },
  );
}

String _safeName(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

String _shortDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';
