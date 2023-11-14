import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:log_tanker/log_tanker.dart";
import "package:readme_tier_list_generator/app.dart";
import "package:readme_tier_list_generator/data/model.dart";
import "package:readme_tier_list_generator/data/parse_yaml.dart";

final RegExp regExp = RegExp(r"<!--tier-list(.*?)-->", dotAll: true);

String extractString(String originalString) {
  final match = regExp.firstMatch(originalString);

  return match?.group(1) ?? "";
}

File readmeFile = File("${Directory.current.path}/README.md");
Directory imageFolder = Directory("${Directory.current.path}/gen_images");
String githubLink = "https://github.com/ObNitram/readme_tier_list_generator";

void main() async {
  QuickLog.i("Start creation of readme tier list");
  WidgetsFlutterBinding.ensureInitialized();

  QuickLog.i("readmePath: ${readmeFile.path}");

  if (!readmeFile.existsSync()) {
    QuickLog.w("README file not found in : \n ${readmeFile.path}");
    SystemNavigator.pop();
    return;
  }

  imageFolder.createSync(recursive: true);
  QuickLog.i("imageFolder: ${imageFolder.path}");

  final yamlConfig = extractString(readmeFile.readAsStringSync());

  if (yamlConfig.isEmpty) {
    QuickLog.w("No yaml config found in README.md, exiting");
    SystemNavigator.pop();
    return;
  }

  TierList tierList = parseYaml(yamlConfig);
  QuickLog.i("TierList title : ${tierList.title}}");

  runApp(App(tierList: tierList));
}
