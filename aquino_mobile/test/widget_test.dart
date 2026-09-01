import 'package:flutter_test/flutter_test.dart';

import 'package:lab_activity/main.dart';
import 'package:lab_activity/screens/cart_screen.dart';
import 'package:lab_activity/screens/splash_screen.dart';

void main() {
  testWidgets('App starts on splash screen and shows the app branding', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Lab Activity'), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    // The splash screen intentionally waits 1.5 seconds before checking auth.
    // Pumping this duration prevents the test from leaving a pending timer behind.
    await tester.pump(const Duration(milliseconds: 1500));
  });

  testWidgets('Cart screen can be created for an authenticated user id', (WidgetTester tester) async {
    const cartScreen = CartScreen(userId: 42);

    expect(cartScreen.userId, 42);
  });
}
