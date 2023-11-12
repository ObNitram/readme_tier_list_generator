import "dart:ui" as ui;
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:log_tanker/log_tanker.dart";
import "package:readme_tier_list_generator/model.dart";
import "package:readme_tier_list_generator/parse_yaml.dart";
import "package:readme_tier_list_generator/rank_category_list_tile.dart";

final RegExp regExp = RegExp(r"<!--tier-list(.*?)-->", dotAll: true);

String extractString(String originalString) {
  final match = regExp.firstMatch(originalString);

  return match?.group(1) ?? "";
}

File readmeFile = File("${Directory.current.path}/README.md");
Directory imageFolder = Directory("${Directory.current.path}/images");

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
  QuickLog.i("Tier-List title : ${tierList.title}}");

  runApp(MyApp(tierList: tierList));
}

class MyApp extends StatelessWidget {
  final GlobalKey _globalKey = GlobalKey();
  final TierList tierList;

  MyApp({required this.tierList, super.key});

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.circular(15.0);
    final Widget repaint = RepaintBoundary(
      key: _globalKey,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: radius,
        ),
        color: Colors.grey[200],
        child: ClipRRect(
            borderRadius: radius,
            child: Column(
              children: [
                Container(
                  color: Colors.blue,
                  height: 80,
                  child: const Center(
                      child: Text("Language Tier List",
                          style: TextStyle(fontSize: 30, color: Colors.white))),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                ),
                for (Tier rank in tierList.tierList.keys)
                  Expanded(
                    child: RankCategoryListTile(
                      rankable: tierList.tierList[rank]!,
                      rank: rank,
                    ),
                  ),
              ],
            )),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => captureImage(context));

    return MaterialApp(
      home: Container(color: Colors.purpleAccent, child: repaint),
    );
  }

  Future<void> captureImage(BuildContext context) async {
    Uint8List pngBytes = await capture();

    String imagePath =
        "${imageFolder.path}/${tierList.title.toLowerCase().replaceAll(" ", "_")}.png";

    File imgFile = File(imagePath);

    await imgFile.writeAsBytes(pngBytes);

    QuickLog.i("Image saved at $imagePath");

    updateReadme(imagePath);

    SystemNavigator.pop();
  }

  Future<Uint8List> capture() async {
    try {
      RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      QuickLog.ensure(boundary != null, "boundary is null");

      final image = await boundary!.toImage(pixelRatio: 6);

      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png) as ByteData;
      final pngBytes = byteData.buffer.asUint8List();

      return pngBytes;
    } catch (e) {
      QuickLog.e("Echec capture", stackTrace: e.toString());
      return Uint8List(0);
    }
  }

  void updateReadme(String imagePath) {
    QuickLog.i("Start update of readme tier list");
    String readmeString = "";

    readmeString = readmeFile.readAsStringSync();

    String schema = "<!--tier-list${extractString(readmeString)}-->";

    final String imageLocalPath =
        imagePath.replaceAll(Directory.current.path, "");

    readmeString = readmeString.replaceAll(
        schema, "![languages_tier-list.png]($imageLocalPath)\n$schema");

    readmeFile.writeAsStringSync(readmeString);
  }
}
