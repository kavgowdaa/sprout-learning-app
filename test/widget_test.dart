import 'package:flutter_test/flutter_test.dart';
import 'package:app_task4/main.dart';

void main() {
  testWidgets('Sprout app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SproutApp());

    expect(find.text('Sprout 🌱'), findsOneWidget);
  });
}