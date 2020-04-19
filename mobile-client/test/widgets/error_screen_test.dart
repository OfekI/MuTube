import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mutube/localizations.dart';
import 'package:mutube/widgets/error_screen.dart';

void main() {
  group('ErrorScreen', () {
    testWidgets('displays informative text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        supportedLocales: [Locale('en', 'US')],
        localizationsDelegates: [AppLocalizations.delegate],
        home: ErrorScreen(),
      ));

      await tester.pump();

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(
        find.text('Unfortunately, an error has occurred.'),
        findsOneWidget,
      );
      expect(find.text('Please restart the app.'), findsOneWidget);
    });
    testWidgets('displays localized text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        supportedLocales: [Locale('it', 'IT')],
        localizationsDelegates: [AppLocalizations.delegate],
        home: ErrorScreen(),
      ));

      await tester.pump();

      expect(find.text('Unfortunately, an error has occurred.'), findsNothing);
      expect(find.text('Purtroppo, c\'è stato un errore.'), findsOneWidget);
      expect(find.text("Per favore riavvia l'app."), findsOneWidget);
    });
  });
}
