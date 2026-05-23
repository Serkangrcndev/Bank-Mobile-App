import 'package:flutter_test/flutter_test.dart';
import 'package:bank_app/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BankApp());
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
