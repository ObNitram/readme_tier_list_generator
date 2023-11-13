import "dart:io";

import "package:flutter/material.dart";
import "package:log_tanker/log_tanker.dart";
import 'package:flutter_svg/flutter_svg.dart';
import "package:readme_tier_list_generator/gen/icons.dart";

class TierList {
  final String title;
  final Map<Tier, List<RankableItem>> tierList;
  final String yamlConfig;

  TierList(
      {required this.title, required this.tierList, required this.yamlConfig});

  TierList.defaultTierList() : this(title: "", tierList: {}, yamlConfig: "");

  String get imageName =>
      "${title.trim().replaceAllMapped(RegExp(r"\W+"), (match) => "_").toLowerCase()}.png";
}

class Tier {
  final String name;
  final Color color;

  Tier({required this.name, String? colorHex}) : color = _parseColor(colorHex);

  static Color _parseColor(String? colorHex) {
    final validHexColor = RegExp(r"^#([A-Fa-f0-9]{6})$");

    if (colorHex != null && validHexColor.hasMatch(colorHex)) {
      return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
    } else {
      return Colors.blue;
    }
  }
}

class RankableItem {
  final String name;

  RankableItem({required this.name});

  Widget toWidget() {
    if (name.startsWith("icons/")) {
      File imageFile = File("${Directory.current.path}/assets/$name");
      if (imageFile.existsSync()) {
        return SvgPicture.string(
          imageFile.readAsStringSync(),
          placeholderBuilder: (context) => const Text("Icon loading"),
        );
      } else {
        QuickLog.w("Image file not found in : \n ${imageFile.path}");
        return Text(name);
      }
    }

    if (customIconAssociation.containsKey(name.trim().toLowerCase())) {
      File imageFile = File(
          "${Directory.current.path}/assets/${customIconAssociation[name.trim().toLowerCase()]}");
      if (imageFile.existsSync()) {
        return SvgPicture.string(
          imageFile.readAsStringSync(),
          placeholderBuilder: (context) => const Text("Icon loading"),
        );
      } else {
        QuickLog.e("Custom image file not found in : \n ${imageFile.path}");
        return Text(name);
      }
    }

    return Text(name);
  }
}
