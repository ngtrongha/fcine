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
    version: (json['version'] as num?)?.toInt() ?? 1,
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    sources: ((json['sources'] as List?) ?? [])
        .map((e) => SourceConfig.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    settings: AppSettings.fromJson(
      Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    ),
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'updatedAt': updatedAt.toIso8601String(),
    'sources': sources.map((s) => s.toJson()).toList(),
    'settings': settings.toJson(),
  };

  /// True khi user đã nhập ít nhất 1 nguồn được bật.
  /// App dùng cờ này để quyết định: chế độ browse online hay player-only.
  bool get hasSource => sources.any((s) => s.enabled && s.baseUrl.isNotEmpty);

  List<SourceConfig> get enabledSources =>
      sources.where((s) => s.enabled && s.baseUrl.isNotEmpty).toList();

  factory MasterConfig.empty() => MasterConfig(
    version: 1,
    updatedAt: DateTime.now(),
    sources: const [],
    settings: AppSettings.defaults(),
  );

  SourceConfig get kkphim => sources.firstWhere((s) => s.id == 'kkphim');
  SourceConfig get nguonc => sources.firstWhere((s) => s.id == 'nguonc');
  SourceConfig? get enabledSource =>
      sources.where((s) => s.enabled && s.baseUrl.isNotEmpty).firstOrNull;
}

class SourceConfig {
  final String id;
  final String name;
  final bool enabled;

  /// Loại nguồn: 'api' (JSON như KKPhim) hoặc 'web' (băm HTML bất kỳ web phim nào).
  final String sourceType;
  final String baseUrl;
  final List<String> fallbackUrls;
  final String cdnImage;
  final Map<String, String> headers;
  final Endpoints endpoints;
  final Map<String, dynamic> extractors;

  /// CSS selectors cho nguồn web (bỏ qua với nguồn api).
  /// Xem [WebSelectors] để biết key chuẩn + preset DooPlay.
  final Map<String, dynamic> selectors;
  final Map<String, dynamic> pagination;

  bool get isWeb => sourceType == 'web';

  SourceConfig({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.fallbackUrls,
    required this.cdnImage,
    required this.headers,
    required this.endpoints,
    this.enabled = true,
    this.sourceType = 'api',
    this.extractors = const {},
    this.selectors = const {},
    this.pagination = const {},
  });

  factory SourceConfig.fromJson(Map<String, dynamic> json) => SourceConfig(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    enabled: json['enabled'] ?? true,
    sourceType: json['sourceType']?.toString() ?? 'api',
    baseUrl: json['baseUrl']?.toString() ?? '',
    fallbackUrls:
        (json['fallbackUrls'] as List?)?.map((e) => e.toString()).toList() ??
        [],
    cdnImage: json['cdnImage']?.toString() ?? 'https://phimimg.com',
    headers: Map<String, String>.from(json['headers'] ?? {}),
    endpoints: Endpoints.fromJson(
      Map<String, dynamic>.from(json['endpoints'] as Map? ?? {}),
    ),
    extractors: json['extractors'] != null
        ? Map<String, dynamic>.from(json['extractors'] as Map)
        : {},
    selectors: json['selectors'] != null
        ? Map<String, dynamic>.from(json['selectors'] as Map)
        : {},
    pagination: json['pagination'] != null
        ? Map<String, dynamic>.from(json['pagination'] as Map)
        : {},
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'enabled': enabled,
    'sourceType': sourceType,
    'baseUrl': baseUrl,
    'fallbackUrls': fallbackUrls,
    'cdnImage': cdnImage,
    'headers': headers,
    'endpoints': endpoints.toJson(),
    'extractors': extractors,
    'selectors': selectors,
    'pagination': pagination,
  };

  /// Đọc 1 selector CSS (String) cho nguồn web, fallback [fallback].
  String webSelector(String key, [String fallback = '']) {
    final v = selectors[key];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return fallback;
  }

  SourceConfig copyWith({
    String? id,
    String? name,
    bool? enabled,
    String? sourceType,
    String? baseUrl,
    List<String>? fallbackUrls,
    String? cdnImage,
    Map<String, String>? headers,
    Endpoints? endpoints,
    Map<String, dynamic>? extractors,
    Map<String, dynamic>? selectors,
    Map<String, dynamic>? pagination,
  }) => SourceConfig(
    id: id ?? this.id,
    name: name ?? this.name,
    enabled: enabled ?? this.enabled,
    sourceType: sourceType ?? this.sourceType,
    baseUrl: baseUrl ?? this.baseUrl,
    fallbackUrls: fallbackUrls ?? this.fallbackUrls,
    cdnImage: cdnImage ?? this.cdnImage,
    headers: headers ?? this.headers,
    endpoints: endpoints ?? this.endpoints,
    extractors: extractors ?? this.extractors,
    selectors: selectors ?? this.selectors,
    pagination: pagination ?? this.pagination,
  );

  /// Get extractor config for a section (latest, search, detail, episodes)
  Map<String, dynamic> extractor(String section) {
    final raw = extractors[section];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  /// Get extractor path for a field
  String? extractorPath(String section, String field) {
    final sectionConfig = extractor(section);
    return sectionConfig[field] as String?;
  }
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
    latest: Endpoint.fromJson(
      Map<String, dynamic>.from(json['latest'] as Map? ?? {'path': '/', 'method': 'GET'}),
    ),
    latestV1: json['latestV1'] != null
        ? Endpoint.fromJson(Map<String, dynamic>.from(json['latestV1'] as Map))
        : null,
    search: Endpoint.fromJson(
      Map<String, dynamic>.from(json['search'] as Map? ?? {'path': '/', 'method': 'GET'}),
    ),
    detail: Endpoint.fromJson(
      Map<String, dynamic>.from(json['detail'] as Map? ?? {'path': '/', 'method': 'GET'}),
    ),
    listByType: json['listByType'] != null
        ? Endpoint.fromJson(Map<String, dynamic>.from(json['listByType'] as Map))
        : null,
  );

  Map<String, dynamic> toJson() => {
    'latest': latest.toJson(),
    if (latestV1 != null) 'latestV1': latestV1!.toJson(),
    'search': search.toJson(),
    'detail': detail.toJson(),
    if (listByType != null) 'listByType': listByType!.toJson(),
  };
}

class Endpoint {
  final String path;
  final String method;
  Endpoint({required this.path, required this.method});
  factory Endpoint.fromJson(Map<String, dynamic> json) =>
      Endpoint(path: json['path']?.toString() ?? '/', method: json['method']?.toString() ?? 'GET');

  Map<String, dynamic> toJson() => {'path': path, 'method': method};
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

  Map<String, dynamic> toJson() => {
    'searchDebounceMs': searchDebounceMs,
    'requestTimeoutMs': requestTimeoutMs,
    'imageCacheMaxMb': imageCacheMaxMb,
    'playerHeadersRequired': playerHeadersRequired,
  };

  static AppSettings defaults() => AppSettings(
    searchDebounceMs: 400,
    requestTimeoutMs: 8000,
    imageCacheMaxMb: 100,
    playerHeadersRequired: false,
  );
}

Future<MasterConfig> loadMasterConfigFromAssets(String jsonStr) async {
  final map = jsonDecode(jsonStr) as Map<String, dynamic>;
  return MasterConfig.fromJson(map);
}
