import 'package:flutter_test/flutter_test.dart';
import 'package:homeguru/main.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeGuruApp());
    expect(find.text('HomeGuru'), findsOneWidget);
  });
}
