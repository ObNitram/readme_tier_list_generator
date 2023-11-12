import "package:flutter_test/flutter_test.dart";
import "package:readme_tier_list_generator/main.dart";
import "package:readme_tier_list_generator/parse_yaml.dart";

void main() {
  testWidgets("", (tester) async {
    await tester.pumpWidget(
      MyApp(tierList: {}),
      Duration(seconds: 2),
      EnginePhase.paint,
    );

    // await expectLater(
    //   find.byType(SomeWidget),
    //   matchesGoldenFile("someWidget.png"),
    // );
  });
}
