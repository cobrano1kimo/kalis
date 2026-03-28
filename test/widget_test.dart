import 'package:flutter_test/flutter_test.dart';
import 'package:photo_compare/app.dart';

void main() {
  testWidgets('App loads home title', (WidgetTester tester) async {
    await tester.pumpWidget(const PhotoCompareApp());
    await tester.pumpAndSettle();

    expect(find.text('Photo Compare'), findsOneWidget);
    expect(find.text('前後對比拼接'), findsOneWidget);
  });
}
