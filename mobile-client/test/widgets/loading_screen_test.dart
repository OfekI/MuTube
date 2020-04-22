import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mutube/services/services.dart';
import 'package:mutube/widgets/loading_screen.dart';

void main() {
  group('LoadingScreen', () {
    testWidgets('displays informative text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        supportedLocales: [Locale('en', 'US')],
        localizationsDelegates: [AppLocalizations.delegate],
        home: LoadingScreen(),
      ));

      await tester.pump();

      expect(find.byIcon(Icons.watch_later), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });
    testWidgets('displays localized text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        supportedLocales: [Locale('it', 'IT')],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        home: LoadingScreen(),
      ));

      await tester.pump();

      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Caricamento in corso...'), findsOneWidget);
    });
  });
}
