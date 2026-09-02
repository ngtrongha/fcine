class EpisodeServer {
  final String serverName;
  final List<Episode> episodes;
  const EpisodeServer({required this.serverName, required this.episodes});
}

class Episode {
  final String name; // "Tập 1", "Full"
  final String slug;
  final String? filename;
  final String? m3u8Url;
  final String? embedUrl;

  const Episode({
    required this.name,
    required this.slug,
    this.filename,
    this.m3u8Url,
    this.embedUrl,
  });

  /// Get the best available URL for playback
  String? get playbackUrl => m3u8Url ?? embedUrl;
  bool get hasM3u8 => m3u8Url != null && m3u8Url!.isNotEmpty;
  bool get hasEmbed => embedUrl != null && embedUrl!.isNotEmpty;

  // Backward compatibility getters
  String get linkM3u8 => m3u8Url ?? embedUrl ?? '';
  String get linkEmbed => embedUrl ?? '';
}
