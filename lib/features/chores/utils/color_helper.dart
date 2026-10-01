import 'package:flutter/material.dart';

class ColorHelper {
  ColorHelper._();

  static Color parseHexColor(String? colorStr, {Color fallback = const Color(0xFFE06A47)}) {
    if (colorStr == null || colorStr.trim().isEmpty) return fallback;
    final trimmed = colorStr.trim();

    // Check rgba / rgb
    final rgbMatch = RegExp(r'rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*([\d.]+))?\s*\)').firstMatch(trimmed);
    if (rgbMatch != null) {
      final r = int.tryParse(rgbMatch.group(1)!) ?? 0;
      final g = int.tryParse(rgbMatch.group(2)!) ?? 0;
      final b = int.tryParse(rgbMatch.group(3)!) ?? 0;
      final aStr = rgbMatch.group(4);
      final a = aStr != null ? ((double.tryParse(aStr) ?? 1.0) * 255).round() : 255;
      return Color.fromARGB(a.clamp(0, 255), r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
    }

    var hex = trimmed.replaceAll('#', '');

    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join('');
    }

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    if (hex.length == 8) {
      final val = int.tryParse(hex, radix: 16);
      if (val != null) return Color(val);
    }

    return fallback;
  }

  static BoxDecoration parseBgDecoration(
    String? bgStr, {
    double borderRadius = 14,
    bool isCircle = false,
  }) {
    if (bgStr == null || bgStr.trim().isEmpty) {
      return BoxDecoration(
        color: const Color(0xFF8A7F6E),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
      );
    }

    final trimmed = bgStr.trim();

    if (trimmed.contains('linear-gradient')) {
      final gradient = _parseLinearGradient(trimmed);
      if (gradient != null) {
        return BoxDecoration(
          gradient: gradient,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        );
      }
    }

    final color = parseHexColor(trimmed, fallback: const Color(0xFF8A7F6E));
    return BoxDecoration(
      color: color,
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
    );
  }

  static LinearGradient? _parseLinearGradient(String gradientStr) {
    try {
      final hexRegex = RegExp(r'#([0-9a-fA-F]{3,8})');
      final matches = hexRegex.allMatches(gradientStr).toList();
      if (matches.length >= 2) {
        final colors = matches.map((m) => parseHexColor(m.group(0)!)).toList();
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        );
      }
    } catch (_) {}
    return null;
  }
}
