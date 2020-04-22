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
  String get loading => Intl.message(
        'Loading...',
        name: 'loading',
        desc: 'Loading',
      );
  String get mobileClientLoginStepTitle => Intl.message(
        'Mobile Client Access Code',
        name: 'mobileClientLoginStepTitle',
        desc: 'Title for Mobile Client step of login flow',
      );
  String get mobileClientLoginStepSubtitle => Intl.message(
        "Obtain and submit an access code for Google Play Music's mobile client.",
        name: 'mobileClientLoginStepSubtitle',
        desc: 'Subtitle for Mobile Client step of login flow',
      );
  String get mobileClientLoginStepButtonLabel => Intl.message(
        'Obtain Mobile Client Access Code',
        name: 'mobileClientLoginStepButtonLabel',
        desc: 'Button label for Mobile Client step of login flow',
      );
  String get mobileClientLoginStepHintText => Intl.message(
        'Paste your mobile client access code here',
        name: 'mobileClientLoginStepHintText',
        desc: 'Hint text for Mobile Client step of login flow',
      );
  String get musicManagerLoginStepTitle => Intl.message(
        'Music Manager Access Code',
        name: 'musicManagerLoginStepTitle',
        desc: 'Title for Music Manager step of login flow',
      );
  String get musicManagerLoginStepSubtitle => Intl.message(
        "Obtain and submit an access code for Google Play Music's music manager.",
        name: 'musicManagerLoginStepSubtitle',
        desc: 'Subtitle for Music Manager step of login flow',
      );
  String get musicManagerLoginStepButtonLabel => Intl.message(
        'Obtain Music Manager Access Code',
        name: 'musicManagerLoginStepButtonLabel',
        desc: 'Button label for Music Manager step of login flow',
      );
  String get musicManagerLoginStepHintText => Intl.message(
        'Paste your music manager access code here',
        name: 'musicManagerLoginStepHintText',
        desc: 'Hint text for Music Manager step of login flow',
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
