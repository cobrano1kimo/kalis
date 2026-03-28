import 'package:flutter_test/flutter_test.dart';
import 'package:kalis/app.dart';

void main() {
  testWidgets('App loads Kalis home title', (WidgetTester tester) async {
    await tester.pumpWidget(const KalisApp());
    await tester.pumpAndSettle();

    expect(find.text('卡莉絲'), findsOneWidget);
    expect(find.textContaining('Photo Compare'), findsWidgets);
  });
}
