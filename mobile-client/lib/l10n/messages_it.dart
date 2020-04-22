// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'it';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "errorOccurred" : MessageLookupByLibrary.simpleMessage("Purtroppo, c\'è stato un errore."),
    "loading" : MessageLookupByLibrary.simpleMessage("Caricamento in corso..."),
    "mobileClientLoginStepButtonLabel" : MessageLookupByLibrary.simpleMessage("Ottiene codice del client mobile"),
    "mobileClientLoginStepHintText" : MessageLookupByLibrary.simpleMessage("Incolla il codice del client mobile qui"),
    "mobileClientLoginStepSubtitle" : MessageLookupByLibrary.simpleMessage("Ottiene e invia un codice di accesso per il client mobile di Google Play Musica."),
    "mobileClientLoginStepTitle" : MessageLookupByLibrary.simpleMessage("Codice di accesso del client mobile"),
    "musicManagerLoginStepButtonLabel" : MessageLookupByLibrary.simpleMessage("Ottiene codice del direttore di musica"),
    "musicManagerLoginStepHintText" : MessageLookupByLibrary.simpleMessage("Incolla il codice del direttore di musica qui"),
    "musicManagerLoginStepSubtitle" : MessageLookupByLibrary.simpleMessage("Ottiene e invia un codice di accesso per il direttore di musica di Google Play Musica."),
    "musicManagerLoginStepTitle" : MessageLookupByLibrary.simpleMessage("Codice di accesso del direttore di musica"),
    "restartApp" : MessageLookupByLibrary.simpleMessage("Per favore riavvia l\'app."),
    "title" : MessageLookupByLibrary.simpleMessage("MuTube")
  };
}
