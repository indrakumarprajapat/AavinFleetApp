class CalculationsUtil {
  static double roundToNearestQuarterThenToInt(String value, double incrementBy) {
    final double doubleValue = double.tryParse(value) ?? 0.0;
    
    if (doubleValue < 0 || !doubleValue.isFinite) {
      return 0;
    }

    if (incrementBy <= 0 || !incrementBy.isFinite) {
      return doubleValue.roundToDouble();
    }

    final double result = (doubleValue / incrementBy).round() * incrementBy;

    return result.isFinite ? result : 0;
  }
}

