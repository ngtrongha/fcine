import '../../domain/entities/episode.dart';

class EpisodeModel extends Episode {
  const EpisodeModel({
    required super.name,
    required super.slug,
    super.filename,
    super.m3u8Url,
    super.embedUrl,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
        filename: json['filename'],
        m3u8Url: json['link_m3u8'] ?? json['m3u8'],
        embedUrl: json['link_embed'] ?? json['embed'],
      );
}

class EpisodeServerModel extends EpisodeServer {
  const EpisodeServerModel({required super.serverName, required super.episodes});

  factory EpisodeServerModel.fromJson(Map<String, dynamic> json) => EpisodeServerModel(
        serverName: json['server_name'] ?? 'Vietsub',
        episodes: (json['server_data'] as List?)
                ?.map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
