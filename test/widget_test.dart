import 'package:flutter_test/flutter_test.dart';
import 'package:et0126_ethereal/main.dart';

void main() {
  testWidgets('Ethereal app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EtherealApp());
    expect(find.text('Ethereal'), findsOneWidget);
  });
}
