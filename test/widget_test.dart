import 'package:flutter_test/flutter_test.dart';
import 'package:the_volt/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TheVoltApp());
    expect(find.text('The Volt'), findsOneWidget);
  });
}
