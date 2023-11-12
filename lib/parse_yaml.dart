import "package:log_tanker/log_tanker.dart";
import "package:readme_tier_list_generator/model.dart";
import "package:yaml/yaml.dart";

TierList parseYaml(String yamlString) {
  final yamlMap = loadYaml(yamlString.trim());

  if (yamlMap == null) {
    QuickLog.e("No yaml string not loadable to yaml map, exiting");
    return TierList.defaultTierList();
  }

  QuickLog.d("yamlMap: $yamlMap");

  final Map<Tier, List<RankableItem>> tierList = {};

  for (String key in yamlMap.keys) {
    List<RankableItem> rankableList = [];

    if (key == "title") {
      continue;
    }

    for (final rankable in yamlMap[key]["rankable"]) {
      rankableList.add(RankableItem(name: rankable));
    }

    tierList[Tier(name: key, colorHex: yamlMap[key]["color"])] = rankableList;
  }
  return TierList(title: yamlMap["title"], tierList: tierList);
}
