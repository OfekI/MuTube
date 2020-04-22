import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mutube/models/models.dart';
import 'package:mutube/services/services.dart';
import 'package:mutube/widgets/widgets.dart';
import 'package:optional/optional.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

final credential = OAuth2Credentials(
  accessToken: 'foo',
  clientId: 'bar',
  clientSecret: 'baz',
  refreshToken: 'quux',
  revokeUri: 'foo:bar',
  scopes: ['https://foo.com/bar'],
  tokenExpiry: 10,
  userAgent: 'grault',
  tokenUri: 'bar:baz',
  tokenInfoUri: 'baz:quux',
);
final Map<String, dynamic> oAuthClientJson = {
  'authUrl': {'authority': 'foo.com', 'path': 'bar'},
  'redirectUri': 'foo:bar:baz',
  'accessType': 'foo',
  'responseType': 'grault',
  'revokeUrl': {'authority': 'bar.com', 'path': 'baz'},
  'tokenUrl': {'authority': 'baz.com', 'path': 'quux'},
  'tokenInfoUrl': {'authority': 'quux.com', 'path': 'corge'},
  'clientId': 'garply',
  'clientSecret': 'plugh',
  'scope': 'foo.com/bar',
};
final config = AppConfig(
    googleMusicOAuth: GoogleMusicOAuth(
  mobileClient: GoogleMusicOAuthClient.fromJson(oAuthClientJson),
  musicManager: GoogleMusicOAuthClient.fromJson({
    ...oAuthClientJson,
    'clientId': 'foo',
    'clientSecret': 'bar',
    'scope': 'bar.com/baz',
  }),
));

abstract class _MockInterface {
  void launch(String url);
}

class _Mock extends Mock implements _MockInterface {}

class _AuthService extends AuthService {
  final void Function(String) launch;
  _AuthService({this.launch}) : super();

  @override
  void obtainAccessCode(GoogleMusicOAuthClient client,
          {void Function(String) launch = urlLauncher.launch}) =>
      super.obtainAccessCode(client, launch: this.launch);

  @override
  Future<Optional<OAuth2Credentials>> getCredentials(
    GoogleMusicOAuthClient client,
    String code, {
    Future<http.Response> Function(Uri, {Map<String, dynamic> body}) post =
        http.post,
  }) async =>
      code == 'foo' ? Optional.of(credential) : Optional.empty();
}

void main() {
  group('LoginFlow', () {
    group('if authenticated', () {
      testWidgets('displays child', (tester) async {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
          AuthService.musicManagerCredentialsKey:
              jsonEncode(credential.toJson()),
        });
        await tester.pumpWidget(Provider<AuthService>(
          create: (_) => AuthService(),
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: LoginFlow(
              child: Text('test'),
            ),
          ),
        ));

        await tester.pumpAndSettle();

        expect(find.text('test'), findsOneWidget);
        expect(find.byType(Stepper), findsNothing);
        expect(find.byType(ErrorScreen), findsNothing);
        expect(find.byType(LoadingScreen), findsNothing);
      });
      testWidgets('provides credentials to descendants', (tester) async {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
          AuthService.musicManagerCredentialsKey:
              jsonEncode(credential.toJson()),
        });
        await tester.pumpWidget(Provider<AuthService>(
          create: (_) => AuthService(),
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: LoginFlow(
              child: Consumer<GoogleMusicCredentials>(
                builder: (context, value, _) =>
                    value.mobileClient == credential &&
                            value.musicManager == credential
                        ? Text('passed')
                        : Text('failed'),
              ),
            ),
          ),
        ));

        await tester.pumpAndSettle();

        expect(find.text('passed'), findsOneWidget);
        expect(find.text('failed'), findsNothing);
      });
      testWidgets('displays login stepper after log out', (tester) async {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
          AuthService.musicManagerCredentialsKey:
              jsonEncode(credential.toJson()),
        });
        AuthService auth;
        await tester.pumpWidget(MultiProvider(
          providers: <Provider>[
            Provider<AppConfig>.value(value: config),
            Provider<AuthService>(create: (_) {
              auth = AuthService();
              return auth;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: Scaffold(body: LoginFlow(child: Text('testing'))),
          ),
        ));

        await tester.pumpAndSettle();
        expect(find.text('testing'), findsOneWidget);
        expect(find.byType(Stepper), findsNothing);

        auth.logOut();

        await tester.pumpAndSettle();
        expect(find.text('testing'), findsNothing);
        expect(find.byType(Stepper), findsOneWidget);
      });
    });
    group('if unauthenticated', () {
      testWidgets('displays first step of stepper', (tester) async {
        SharedPreferences.setMockInitialValues({});
        await tester.pumpWidget(MultiProvider(
          providers: <Provider>[
            Provider<AppConfig>.value(value: config),
            Provider<AuthService>(create: (_) => AuthService()),
          ],
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: Scaffold(body: LoginFlow(child: Text(''))),
          ),
        ));

        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (value) => value is Stepper && value.currentStep == 0,
          ),
          findsOneWidget,
        );
      });
      testWidgets('launches mobile client url when button tapped',
          (tester) async {
        SharedPreferences.setMockInitialValues({});
        final mock = _Mock();
        await tester.pumpWidget(MultiProvider(
          providers: <Provider>[
            Provider<AppConfig>.value(value: config),
            Provider<AuthService>(
              create: (_) => _AuthService(launch: mock.launch),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: Scaffold(body: LoginFlow(child: Text(''))),
          ),
        ));

        await tester.pumpAndSettle();

        final mobileClientButtonFinder = find.byWidgetPredicate((value) {
          if (value is RaisedButton) {
            if (value.child is Row) {
              final row = value.child as Row;
              if (row.children[0] is Text) {
                final text = row.children[0] as Text;
                return text.data.toLowerCase().contains('mobile client');
              }
            }
          }
          return false;
        });

        await tester.tap(mobileClientButtonFinder);
        await tester.pumpAndSettle();

        verify(
          mock.launch(config.googleMusicOAuth.mobileClient.authUrl.toString()),
        ).called(1);
      });
      testWidgets('steps forward when mobile client access code submitted',
          (tester) async {
        await tester.pumpWidget(MultiProvider(
          providers: <Provider>[
            Provider<AppConfig>.value(value: config),
            Provider<AuthService>(create: (_) => _AuthService()),
          ],
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: Scaffold(body: LoginFlow(child: Text(''))),
          ),
        ));

        await tester.pumpAndSettle();

        final mobileClientTextFieldFinder = find.byWidgetPredicate((value) {
          if (value is TextField) {
            return value.decoration.hintText
                .toLowerCase()
                .contains('mobile client');
          }
          return false;
        });

        await tester.tap(mobileClientTextFieldFinder);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (value) => value is Stepper && value.currentStep == 0,
          ),
          findsOneWidget,
        );

        await tester.enterText(mobileClientTextFieldFinder, 'foo');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (value) => value is Stepper && value.currentStep == 1,
          ),
          findsOneWidget,
        );
      });
    });
    group('if mobile client credentials present', () {
      testWidgets('displays second step of stepper', (tester) async {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
        });
        await tester.pumpWidget(MultiProvider(
          providers: <Provider>[
            Provider<AppConfig>.value(value: config),
            Provider<AuthService>(create: (_) => AuthService()),
          ],
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: Scaffold(body: LoginFlow(child: Text(''))),
          ),
        ));

        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (value) => value is Stepper && value.currentStep == 1,
          ),
          findsOneWidget,
        );
      });
      testWidgets('launches music manager url when button tapped',
          (tester) async {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
        });
        final mock = _Mock();
        await tester.pumpWidget(MultiProvider(
          providers: <Provider>[
            Provider<AppConfig>.value(value: config),
            Provider<AuthService>(
              create: (_) => _AuthService(launch: mock.launch),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: Scaffold(body: LoginFlow(child: Text(''))),
          ),
        ));

        await tester.pumpAndSettle();

        final mobileClientButtonFinder = find.byWidgetPredicate((value) {
          if (value is RaisedButton) {
            if (value.child is Row) {
              final row = value.child as Row;
              if (row.children[0] is Text) {
                final text = row.children[0] as Text;
                return text.data.toLowerCase().contains('music manager');
              }
            }
          }
          return false;
        });

        await tester.tap(mobileClientButtonFinder);
        await tester.pumpAndSettle();

        verify(
          mock.launch(config.googleMusicOAuth.musicManager.authUrl.toString()),
        ).called(1);
      });
      testWidgets('logs in when music manager access code submitted',
          (tester) async {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
        });
        await tester.pumpWidget(MultiProvider(
          providers: <Provider>[
            Provider<AppConfig>.value(value: config),
            Provider<AuthService>(create: (_) => _AuthService()),
          ],
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: Scaffold(body: LoginFlow(child: Text('testing'))),
          ),
        ));

        await tester.pumpAndSettle();

        final mobileClientTextFieldFinder = find.byWidgetPredicate((value) {
          if (value is TextField) {
            return value.decoration.hintText
                .toLowerCase()
                .contains('music manager');
          }
          return false;
        });

        await tester.tap(mobileClientTextFieldFinder);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (value) => value is Stepper && value.currentStep == 1,
          ),
          findsOneWidget,
        );

        await tester.enterText(mobileClientTextFieldFinder, 'foo');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(find.text('testing'), findsOneWidget);
      });
    });
    testWidgets('displays localized text', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(MultiProvider(
        providers: <Provider>[
          Provider<AppConfig>.value(value: config),
          Provider<AuthService>(create: (_) => AuthService()),
        ],
        child: MaterialApp(
          supportedLocales: [Locale('it', 'IT')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          home: Scaffold(body: LoginFlow(child: Text(''))),
        ),
      ));

      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((value) =>
            value is Text &&
            value.data.toLowerCase().contains('direttore di musica')),
        findsNWidgets(4),
      );
    });
    testWidgets('displays error screen if there is an auth error',
        (tester) async {
      await tester.pumpWidget(Provider<AuthService>(
        create: (_) => AuthService.withError(),
        child: MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate],
          home: LoginFlow(
            child: Text('test'),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(ErrorScreen), findsOneWidget);
    });
    testWidgets('displays loading screen if no auth data', (tester) async {
      await tester.pumpWidget(Provider<AuthService>(
        create: (_) => AuthService.withNoData(),
        child: MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate],
          home: LoginFlow(
            child: Text('test'),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(LoadingScreen), findsOneWidget);
    });
  });
}
