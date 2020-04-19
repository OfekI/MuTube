import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mutube/l10n/messages_all.dart';
import 'package:optional/optional.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) async {
    final name = Optional.ofNullable(locale.countryCode)
        .map((_) => locale.toString())
        .orElse(locale.languageCode);
    final localeName = Intl.canonicalizedLocale(name);

    await initializeMessages(localeName);
    Intl.defaultLocale = localeName;
    return AppLocalizations();
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get title => Intl.message(
        'MuTube',
        name: 'title',
        desc: 'The application title',
      );
  String get errorOccurred => Intl.message(
        'Unfortunately, an error has occurred.',
        name: 'errorOccurred',
        desc: 'An error has occurred',
      );
  String get restartApp => Intl.message(
        'Please restart the app.',
        name: 'restartApp',
        desc: 'Restart the app',
      );
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'he', 'it'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
