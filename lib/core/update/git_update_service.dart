import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GitUpdateService {
  static const String _kLastCheckKey = 'git_last_check';
  static const String _kCurrentVersionKey = 'git_current_version';
  static const String _kUpdateUrlKey = 'git_update_url';

  static const String _defaultRepo = 'https://api.github.com/repos/ngtrongha/fcine/releases/latest';
  static const String _defaultUpdateUrl = 'https://github.com/ngtrongha/fcine/releases/latest';

  Future<GitUpdateInfo?> checkForUpdates({
    String? repoUrl,
    String? currentVersion,
  }) async {
    repoUrl ??= await getCustomRepoUrl();
    if (repoUrl == _defaultRepo) {
      repoUrl = _defaultRepo.replaceFirst('your-username', 'fcine');
    }
    currentVersion ??= await _getCurrentVersion();

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    ));

    final response = await dio.get(repoUrl);
    if (response.statusCode != 200) {
      return null;
    }

    final data = response.data;
    final latestVersion = data['tag_name']?.toString().replaceFirst('v', '') ?? '';
    final releaseUrl = data['html_url']?.toString() ?? _defaultUpdateUrl;
    final releaseNotes = data['body']?.toString() ?? '';
    final publishedAt = data['published_at']?.toString() ?? '';
    final assets = data['assets'] as List? ?? [];

    String? downloadUrl;
    for (final asset in assets) {
      final name = asset['name']?.toString() ?? '';
      if (name.endsWith('.apk') ||
          name.endsWith('.exe') ||
          name.endsWith('.dmg') ||
          name.endsWith('.AppImage') ||
          name.endsWith('.msix') ||
          name.endsWith('.zip')) {
        downloadUrl = asset['browser_download_url']?.toString();
        break;
      }
    }

    final hasUpdate = _compareVersions(currentVersion, latestVersion) < 0;

    final info = GitUpdateInfo(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      hasUpdate: hasUpdate,
      releaseUrl: releaseUrl,
      downloadUrl: downloadUrl,
      releaseNotes: releaseNotes,
      publishedAt: publishedAt,
    );

    await _saveLastCheck();
    await _saveCurrentVersion(latestVersion);

    return info;
  }

  Future<void> openReleasePage(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<String> downloadUpdate(
    String downloadUrl, {
    void Function(int received, int total)? onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(Uri.parse(downloadUrl).path);
    final filePath = p.join(dir.path, fileName);

    final dio = Dio();
    await dio.download(
      downloadUrl,
      filePath,
      onReceiveProgress: onProgress,
    );

    return filePath;
  }

  Future<void> installUpdate(String filePath) async {
    if (Platform.isWindows) {
      await Process.run(filePath, [], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.run('open', [filePath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [filePath]);
    }
  }

  Future<String> _getCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCurrentVersionKey) ?? '1.0.1';
  }

  Future<void> _saveCurrentVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrentVersionKey, version);
  }

  Future<void> _saveLastCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastCheckKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kLastCheckKey);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  int _compareVersions(String current, String latest) {
    final cParts = current.split('.').map(int.tryParse).map((e) => e ?? 0).toList();
    final lParts = latest.split('.').map(int.tryParse).map((e) => e ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final c = i < cParts.length ? cParts[i] : 0;
      final l = i < lParts.length ? lParts[i] : 0;
      if (c < l) return -1;
      if (c > l) return 1;
    }
    return 0;
  }

  Future<void> setCustomRepoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUpdateUrlKey, url);
  }

  Future<String> getCustomRepoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUpdateUrlKey) ?? _defaultRepo;
  }
}

class GitUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String releaseUrl;
  final String? downloadUrl;
  final String releaseNotes;
  final String publishedAt;

  GitUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.releaseUrl,
    this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
  });

  String get formattedDate {
    try {
      final dt = DateTime.parse(publishedAt);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return publishedAt;
    }
  }
}