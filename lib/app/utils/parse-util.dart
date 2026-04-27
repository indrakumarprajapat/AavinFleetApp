class ParseUtil {
  static bool parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == "1" || value.toLowerCase() == "true";
    return false;
  }

  static int? parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return 0;
  }

  static double? parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return 0.0;
  }
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;

    // Already a DateTime
    if (value is DateTime) return value;

    // If it's a timestamp (milliseconds)
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }

    // If it's a string
    if (value is String) {
      if (value.trim().isEmpty) return null;

      // Try ISO format first (most common)
      try {
        return DateTime.parse(value);
      } catch (_) {}

      // Try parsing as int timestamp string
      final intVal = int.tryParse(value);
      if (intVal != null) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(intVal);
        } catch (_) {}
      }
    }

    return null;
  }
}
