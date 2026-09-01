import 'package:flutter_test/flutter_test.dart';

import 'package:roots/main.dart';

void main() {
  testWidgets('Sprint 0 shell renders', (tester) async {
    await tester.pumpWidget(const RootsApp());

    expect(find.text('PLANT SELFIE'), findsOneWidget);
  });
}
