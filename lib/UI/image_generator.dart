import "dart:ui" as ui;
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:log_tanker/log_tanker.dart";
import "package:readme_tier_list_generator/main.dart";
import "package:readme_tier_list_generator/data/model.dart";
import "package:readme_tier_list_generator/UI/rank_category_list_tile.dart";

class ImageGenerator extends StatelessWidget {
  final GlobalKey _globalKey = GlobalKey();
  final TierList tierList;

  ImageGenerator({required this.tierList, super.key});

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

    WidgetsBinding.instance
        .addPostFrameCallback((_) => postFrameCallBack(context));

    return MaterialApp(
      home: Container(color: Colors.purpleAccent, child: repaint),
    );
  }

  Future<void> postFrameCallBack(BuildContext context) async {
    Uint8List pngBytes = await captureWidgetToPng();
    String imagePath = "${imageFolder.path}/${tierList.imageName}";
    File imgFile = File(imagePath);
    await imgFile.writeAsBytes(pngBytes);
    QuickLog.i("Image saved at $imagePath");

    updateReadme(imagePath);

    SystemNavigator.pop();
  }

  Future<Uint8List> captureWidgetToPng() async {
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

    String schema = "<!--tier-list${tierList.yamlConfig}-->";

    final String imageLocalPath =
        imagePath.replaceAll(Directory.current.path, "");

    String imageLink = "[![${tierList.title}]($imageLocalPath)]($githubLink)\n";

    readmeString = readmeString.replaceAll(schema, "$imageLink$schema");

    readmeString = readmeString.replaceAll(
      "$imageLink$imageLink",
      imageLink,
    );

    readmeFile.writeAsStringSync(readmeString);
  }
}
