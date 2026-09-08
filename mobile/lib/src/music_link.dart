enum MusicService { spotify, appleMusic }

class MusicLink {
  const MusicLink._();

  static String normalize(String input, {MusicService? expectedService}) {
    final value = input.trim();
    final spotifyUri = _spotifyUri(value);
    if (spotifyUri != null &&
        (expectedService == null || expectedService == MusicService.spotify)) {
      return spotifyUri.toString();
    }

    final appleMusicUri = _appleMusicUri(value);
    if (appleMusicUri != null &&
        (expectedService == null ||
            expectedService == MusicService.appleMusic)) {
      return appleMusicUri.toString();
    }

    throw FormatException(switch (expectedService) {
      MusicService.spotify =>
        'Χρησιμοποίησε σύνδεσμο Spotify playlist, album ή track.',
      MusicService.appleMusic =>
        'Χρησιμοποίησε σύνδεσμο Apple Music playlist, album ή τραγουδιού.',
      null => 'Χρησιμοποίησε σύνδεσμο από Spotify ή Apple Music.',
    });
  }

  static bool isSupported(String input) {
    try {
      normalize(input);
      return true;
    } on FormatException {
      return false;
    }
  }

  static MusicService? serviceFor(String input) {
    if (_spotifyUri(input.trim()) != null) return MusicService.spotify;
    if (_appleMusicUri(input.trim()) != null) return MusicService.appleMusic;
    return null;
  }

  static Uri searchUri(MusicService service) => switch (service) {
    MusicService.spotify => Uri.parse(
      'https://open.spotify.com/search/workout',
    ),
    MusicService.appleMusic => Uri.parse(
      'https://music.apple.com/us/search?term=workout',
    ),
  };

  static String serviceName(MusicService service) => switch (service) {
    MusicService.spotify => 'Spotify',
    MusicService.appleMusic => 'Apple Music',
  };

  static Uri? _spotifyUri(String value) {
    if (value.startsWith('spotify:')) {
      final parts = value.split(':');
      if (parts.length == 3 &&
          const {'playlist', 'album', 'track'}.contains(parts[1]) &&
          parts[2].isNotEmpty) {
        return Uri.https('open.spotify.com', '/${parts[1]}/${parts[2]}');
      }
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'open.spotify.com' ||
        uri.pathSegments.length < 2 ||
        !const {
          'playlist',
          'album',
          'track',
        }.contains(uri.pathSegments.first) ||
        uri.pathSegments[1].isEmpty) {
      return null;
    }
    return Uri.https(
      'open.spotify.com',
      '/${uri.pathSegments.take(2).join('/')}',
    );
  }

  static Uri? _appleMusicUri(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'music.apple.com' ||
        uri.pathSegments.length < 3 ||
        !uri.pathSegments.any(
          const {'playlist', 'album', 'song', 'station'}.contains,
        )) {
      return null;
    }
    final trackId = uri.queryParameters['i'];
    return Uri.https(
      'music.apple.com',
      '/${uri.pathSegments.join('/')}',
      trackId == null ? null : {'i': trackId},
    );
  }
}
