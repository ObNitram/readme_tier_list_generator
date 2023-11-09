import "package:readme_tier_list_generator/model.dart";
import "package:yaml/yaml.dart";

Map<Rank, List<Rankable>> parseYaml(String yamlString) {
  final yamlMap = loadYaml(yamlString);
  final Map<Rank, List<Rankable>> tierList = {};

  for (String rank in yamlMap.keys) {
    List<Rankable> rankableList = [];

    for (final rankable in yamlMap[rank]["rankable"]) {
      rankableList.add(Rankable(name: rankable));
    }

    tierList[Rank(name: rank, colorHex: yamlMap[rank]["color"])] = rankableList;
  }
  return tierList;
}
