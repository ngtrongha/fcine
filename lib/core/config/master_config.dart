import 'dart:convert';

class MasterConfig {
  final int version;
  final DateTime updatedAt;
  final List<SourceConfig> sources;
  final AppSettings settings;

  MasterConfig({
    required this.version,
    required this.updatedAt,
    required this.sources,
    required this.settings,
  });

  factory MasterConfig.fromJson(Map<String, dynamic> json) => MasterConfig(
        version: (json['version'] as num).toInt(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
        sources: (json['sources'] as List)
            .map((e) => SourceConfig.fromJson(e as Map<String, dynamic>))
            .toList(),
        settings: AppSettings.fromJson(json['settings'] as Map<String, dynamic>),
      );

  SourceConfig get kkphim => sources.firstWhere((s) => s.id == 'kkphim');
}

class SourceConfig {
  final String id;
  final String name;
  final bool enabled;
  final String baseUrl;
  final List<String> fallbackUrls;
  final String cdnImage;
  final Map<String, String> headers;
  final Endpoints endpoints;

  SourceConfig({
    required this.id,
    required this.name,
    required this.enabled,
    required this.baseUrl,
    required this.fallbackUrls,
    required this.cdnImage,
    required this.headers,
    required this.endpoints,
  });

  factory SourceConfig.fromJson(Map<String, dynamic> json) => SourceConfig(
        id: json['id'],
        name: json['name'],
        enabled: json['enabled'] ?? true,
        baseUrl: json['baseUrl'],
        fallbackUrls: (json['fallbackUrls'] as List).map((e) => e.toString()).toList(),
        cdnImage: json['cdnImage'] ?? 'https://phimimg.com',
        headers: Map<String, String>.from(json['headers'] ?? {}),
        endpoints: Endpoints.fromJson(json['endpoints']),
      );
}

class Endpoints {
  final Endpoint latest;
  final Endpoint? latestV1;
  final Endpoint search;
  final Endpoint detail;
  final Endpoint? listByType;

  Endpoints({
    required this.latest,
    this.latestV1,
    required this.search,
    required this.detail,
    this.listByType,
  });

  factory Endpoints.fromJson(Map<String, dynamic> json) => Endpoints(
        latest: Endpoint.fromJson(json['latest']),
        latestV1: json['latestV1'] != null ? Endpoint.fromJson(json['latestV1']) : null,
        search: Endpoint.fromJson(json['search']),
        detail: Endpoint.fromJson(json['detail']),
        listByType: json['listByType'] != null ? Endpoint.fromJson(json['listByType']) : null,
      );
}

class Endpoint {
  final String path;
  final String method;
  Endpoint({required this.path, required this.method});
  factory Endpoint.fromJson(Map<String, dynamic> json) =>
      Endpoint(path: json['path'], method: json['method'] ?? 'GET');
}

class AppSettings {
  final int searchDebounceMs;
  final int requestTimeoutMs;
  final int imageCacheMaxMb;
  final bool playerHeadersRequired;

  AppSettings({
    required this.searchDebounceMs,
    required this.requestTimeoutMs,
    required this.imageCacheMaxMb,
    required this.playerHeadersRequired,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        searchDebounceMs: (json['searchDebounceMs'] as num?)?.toInt() ?? 400,
        requestTimeoutMs: (json['requestTimeoutMs'] as num?)?.toInt() ?? 8000,
        imageCacheMaxMb: (json['imageCacheMaxMb'] as num?)?.toInt() ?? 100,
        playerHeadersRequired: json['playerHeadersRequired'] ?? false,
      );

  static AppSettings defaults() =>
      AppSettings(searchDebounceMs: 400, requestTimeoutMs: 8000, imageCacheMaxMb: 100, playerHeadersRequired: false);
}

// Helper để load từ assets
Future<MasterConfig> loadMasterConfigFromAssets(String jsonStr) async {
  final map = jsonDecode(jsonStr) as Map<String, dynamic>;
  return MasterConfig.fromJson(map);
}
