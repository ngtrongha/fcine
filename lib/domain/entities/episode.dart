class EpisodeServer {
  final String serverName;
  final List<Episode> episodes;
  const EpisodeServer({required this.serverName, required this.episodes});
}

class Episode {
  final String name; // "Tập 1", "Full"
  final String slug;
  final String filename;
  final String linkM3u8;
  final String linkEmbed;
  const Episode({
    required this.name,
    required this.slug,
    required this.filename,
    required this.linkM3u8,
    required this.linkEmbed,
  });
}
