import "dart:io";

import "package:log_tanker/log_tanker.dart";

Future<Map<String, String>> listFilesInDirectory(String directoryPath) async {
  Directory directory = Directory(directoryPath);

  if (!await directory.exists()) {
    QuickLog.e("Directory does not exist");
    return {};
  }

  Map<String, String> filesMap = {};
  await for (FileSystemEntity entity in directory.list(recursive: true)) {
    if (entity is Directory) {
      String dirName =
          entity.uri.pathSegments[entity.uri.pathSegments.length - 2];

      await for (FileSystemEntity file in entity.list(recursive: false)) {
        if (file is File) {
          if (file.path.endsWith(".svg") && file.path.contains("original")) {
            filesMap[dirName] =
                file.path.replaceAll(directoryPath, "").replaceFirst("/", "");
            continue;
          }
          if (file.path.endsWith(".svg")) {
            filesMap[dirName] =
                file.path.replaceAll(directoryPath, "").replaceFirst("/", "");
            continue;
          }
        }
      }
    }
  }

  return filesMap;
}

final Map<String, List<String>> customKeyRemap = {
  "amazonwebservices": ["aws"],
  "css3": ["css"],
  "html5": ["html"],
  "javascript": ["js"],
  "typescript": ["ts"],
  "cplusplus": ["cpp", "c++"],
  "csharp": ["c#"],
};

final Map<String, String> customIconRemap = {
  "zig": "icons/zig/zig-original.svg",
};

void main() async {
  String directoryPath = "${Directory.current.path}/assets";
  Map<String, String> rawAssociation =
      await listFilesInDirectory(directoryPath);

  String output = "final Map<String, String> customIconAssociation = {";

  rawAssociation.addAll(customIconRemap);

  rawAssociation.forEach((name, path) {
    QuickLog.v("$name: $path");
    output += '"$name": "$path",\n';
  });

  output += "// Manually remapped icons\n";
  customKeyRemap.forEach((name, secondaryNames) {
    for (var secondaryName in secondaryNames) {
      output += '"$secondaryName": "${rawAssociation[name]}",\n';
    }
  });

  output += "};";

  File outputYamlFile = File("${Directory.current.path}/lib/gen/icons.dart");
  outputYamlFile.writeAsStringSync(output);
}
