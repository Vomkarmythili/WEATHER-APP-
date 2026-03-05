import 'package:flutter_test/flutter_test.dart';
import 'package:weatherappvom/main.dart';

Future<void> main() async => testWidgets('App loads with title', (WidgetTester tester) async {
    // Build our weather app
    await tester.pumpWidget(const WeatherApp());

    // Check if AppBar title is present
    expect(find.text('Weather App'), findsOneWidget);
  });
