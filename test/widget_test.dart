import 'package:digital_pet/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Digital Pet app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const DigitalPetApp());

    expect(find.text('Digital Pet'), findsOneWidget);
    expect(find.text('Pip'), findsOneWidget);
    expect(find.text('Happiness'), findsOneWidget);
    expect(find.text('Hunger'), findsOneWidget);
    expect(find.text('Energy'), findsOneWidget);
  });
}