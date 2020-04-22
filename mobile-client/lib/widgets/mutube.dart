import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mutube/models/config.dart';
import 'package:mutube/services/services.dart';
import 'package:mutube/widgets/widgets.dart';
import 'package:provider/provider.dart';

class MuTube extends StatelessWidget {
  final AppConfig config;
  const MuTube({Key key, this.config}) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: <Provider>[
          Provider<AppConfig>.value(value: config),
          Provider<AuthService>(
            create: (context) => AuthService(),
            dispose: (context, auth) => auth.dispose(),
          )
        ],
        child: MaterialApp(
          title: 'MuTube',
          theme: ThemeData(
            primaryColor: Colors.red,
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.red,
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          home: HomePage(),
          supportedLocales: <Locale>[
            Locale('en', 'US'),
            Locale('he', 'IL'),
            Locale('it', 'IT'),
          ],
          localizationsDelegates: <LocalizationsDelegate>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          localeListResolutionCallback: (locales, supportedLocales) =>
              locales.firstWhere(
            (locale) => supportedLocales.any(
              (supportedLocale) =>
                  locale.languageCode == supportedLocale.languageCode &&
                  locale.countryCode == supportedLocale.countryCode,
            ),
            orElse: () => supportedLocales.first,
          ),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).title),
        ),
        body: LoginFlow(
          child: MaterialButton(
            child: Text('Log out'),
            onPressed: () =>
                Provider.of<AuthService>(context, listen: false).logOut(),
          ),
        ),
      );
}
