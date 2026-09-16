/// 1 video/audio file quét được trên thiết bị (thư viện media).
class LocalVideo {
  final String path;
  final String name;
  final String extension;
  final int sizeBytes;
  final DateTime modified;

  const LocalVideo({
    required this.path,
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.modified,
  });

  String get formattedSize {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = sizeBytes.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    final text = size >= 100 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
    return '$text ${units[unit]}';
  }
}
