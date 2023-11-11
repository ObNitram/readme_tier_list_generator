import "dart:ui" as ui;
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:log_tanker/log_tanker.dart";
import "package:readme_tier_list_generator/model.dart";
import "package:readme_tier_list_generator/parse_yaml.dart";
import "package:readme_tier_list_generator/rank_category_list_tile.dart";

void main() async {
  String yamlConfig = "";
  try {
    yamlConfig =
        await File("${Directory.current.path}/tier_list.yaml").readAsString();
  } catch (e) {
    QuickLog.e("tier_list.yaml not found", stackTrace: e.toString());
  }

  runApp(MyApp(tierList: parseYaml(yamlConfig)));
}

class MyApp extends StatelessWidget {
  final GlobalKey _globalKey = GlobalKey();
  final Map<Rank, List<Rankable>> tierList;

  MyApp({required this.tierList, super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => captureImage(context));

    BorderRadiusGeometry radius = BorderRadius.circular(15.0);

    return MaterialApp(
      home: Container(
        color: Colors.purpleAccent,
        child: RepaintBoundary(
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
                              style: TextStyle(
                                  fontSize: 30, color: Colors.white))),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    for (Rank rank in tierList.keys)
                      Expanded(
                        child: RankCategoryListTile(
                          rankable: tierList[rank]!,
                          rank: rank,
                        ),
                      ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Future<void> captureImage(BuildContext context) async {
    Uint8List pngBytes = await capture() as Uint8List;

    String imagePath = "${Directory.current.path}/captured_image.png";

    QuickLog.i("imagePath: $imagePath");

    File imgFile = File(imagePath);

    await imgFile.writeAsBytes(pngBytes);

    SystemNavigator.pop();
  }

  Future<Uint8List?> capture() async {
    try {
      QuickLog.v("Try");

      /// boundary widget by GlobalKey
      RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      QuickLog.ensure(boundary != null, "boundary is null");

      /// convert boundary to image
      final image = await boundary!.toImage(pixelRatio: 6);

      /// set ImageByteFormat
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      QuickLog.e("Error", stackTrace: e.toString());
      return Uint8List(0);
    }
  }
}
