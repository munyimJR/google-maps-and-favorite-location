import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_and_location/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GoogleMapsApp());
    expect(find.text('Google Maps & Location'), findsOneWidget);
  });
}
