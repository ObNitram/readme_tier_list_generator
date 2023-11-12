import "package:flutter/material.dart";

class TierList {
  final String title;
  final Map<Tier, List<RankableItem>> tierList;

  TierList({required this.title, required this.tierList});

  TierList.defaultTierList() : this(title: "", tierList: {});
}

class Tier {
  final String name;
  final Color color;

  Tier({required this.name, String? colorHex}) : color = _parseColor(colorHex);

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

class RankableItem {
  final String name;

  RankableItem({required this.name});
}
