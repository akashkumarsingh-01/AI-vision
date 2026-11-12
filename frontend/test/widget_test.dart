import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Vision AI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VisionAiApp());
    expect(find.text('Vision AI'), findsWidgets);
  });
}
