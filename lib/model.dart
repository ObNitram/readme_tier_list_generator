import "package:flutter/material.dart";

class Rank {
  final String name;
  final Color color;

  Rank({required this.name, String? colorHex}) : color = _parseColor(colorHex);

  // Helper function to parse the color string and return a Color
  static Color _parseColor(String? colorHex) {
    // Regex to check if the string is a valid hex color code
    final validHexColor = RegExp(r"^#([A-Fa-f0-9]{6})$");

    if (colorHex != null && validHexColor.hasMatch(colorHex)) {
      // If the string is a valid hex color code, we use it to create a Color
      return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
    } else {
      // If the string is not valid, we return a default blue color
      return Colors.blue;
    }
  }
}

class Rankable {
  final String name;

  Rankable({required this.name});
}
