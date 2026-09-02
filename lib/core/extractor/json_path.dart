/// Simple JSONPath-like extractor for config-driven parsing.
/// Supports: $.key, $.key.subkey, $.list[*].field
class JsonPathExtractor {
  /// Extract value from JSON using a path like "$.items" or "$.data.items"
  static dynamic extract(dynamic json, String? path) {
    if (path == null || path.isEmpty || json == null) return null;

    // Remove leading "$."
    var remaining = path.startsWith('\$.') ? path.substring(2) : path;

    dynamic current = json;
    while (remaining.isNotEmpty) {
      if (current == null) return null;

      // Handle [*] array wildcard - collect all items
      if (remaining.startsWith('[*]')) {
        remaining = remaining.substring(3);
        if (current is List) {
          if (remaining.isEmpty) return current;
          // Continue with each item
          final results = <dynamic>[];
          for (final item in current) {
            final extracted = extract(item, '\$.$remaining');
            if (extracted is List) {
              results.addAll(extracted);
            } else if (extracted != null) {
              results.add(extracted);
            }
          }
          return results;
        }
        return null;
      }

      // Get next key segment
      final dotIndex = remaining.indexOf('.');
      final bracketIndex = remaining.indexOf('[');
      String key;
      if (dotIndex == -1 && bracketIndex == -1) {
        key = remaining;
        remaining = '';
      } else if (bracketIndex == -1) {
        key = remaining.substring(0, dotIndex);
        remaining = remaining.substring(dotIndex + 1);
      } else if (dotIndex == -1 || bracketIndex < dotIndex) {
        key = remaining.substring(0, bracketIndex);
        remaining = remaining.substring(bracketIndex);
      } else {
        key = remaining.substring(0, dotIndex);
        remaining = remaining.substring(dotIndex + 1);
      }

      if (current is Map<String, dynamic>) {
        current = current[key];
      } else if (current is List) {
        // Try to parse as index
        final index = int.tryParse(key);
        if (index != null && index < current.length) {
          current = current[index];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }

    return current;
  }

  /// Extract a string value
  static String? extractString(dynamic json, String? path, {String? fallback}) {
    final value = extract(json, path);
    if (value == null) return fallback;
    return value.toString();
  }

  /// Extract an int value
  static int? extractInt(dynamic json, String? path, {int? fallback}) {
    final value = extract(json, path);
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  /// Extract a double value
  static double? extractDouble(dynamic json, String? path, {double? fallback}) {
    final value = extract(json, path);
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  /// Extract a list of maps
  static List<Map<String, dynamic>> extractMapList(dynamic json, String? path) {
    final value = extract(json, path);
    if (value is List) {
      return value.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
