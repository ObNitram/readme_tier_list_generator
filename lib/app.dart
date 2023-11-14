import "dart:ui" as ui;
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:log_tanker/log_tanker.dart";
import "package:readme_tier_list_generator/UI/image_generator.dart";
import "package:readme_tier_list_generator/main.dart";
import "package:readme_tier_list_generator/data/model.dart";

class App extends StatelessWidget {
  final GlobalKey _globalKey = GlobalKey();
  final TierList tierList;

  App({required this.tierList, super.key});

  @override
  Widget build(BuildContext context) {
    final Widget repaint = SizedBox(
      width: 800,
      height: 500,
      child: RepaintBoundary(
        key: _globalKey,
        child: TierListWidget(tierList: tierList),
      ),
    );

    if (true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
            const Duration(seconds: 5),
            () => postFrameCallBack(context),
          ));
    }

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

      final image = await boundary!.toImage(pixelRatio: 1);

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
