// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
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
  String get localeName => 'messages';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "errorOccurred" : MessageLookupByLibrary.simpleMessage("Unfortunately, an error has occurred."),
    "loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "mobileClientLoginStepButtonLabel" : MessageLookupByLibrary.simpleMessage("Obtain Mobile Client Access Code"),
    "mobileClientLoginStepHintText" : MessageLookupByLibrary.simpleMessage("Paste your mobile client access code here"),
    "mobileClientLoginStepSubtitle" : MessageLookupByLibrary.simpleMessage("Obtain and submit an access code for Google Play Music\'s mobile client."),
    "mobileClientLoginStepTitle" : MessageLookupByLibrary.simpleMessage("Mobile Client Access Code"),
    "musicManagerLoginStepButtonLabel" : MessageLookupByLibrary.simpleMessage("Obtain Music Manager Access Code"),
    "musicManagerLoginStepHintText" : MessageLookupByLibrary.simpleMessage("Paste your music manager access code here"),
    "musicManagerLoginStepSubtitle" : MessageLookupByLibrary.simpleMessage("Obtain and submit an access code for Google Play Music\'s music manager."),
    "musicManagerLoginStepTitle" : MessageLookupByLibrary.simpleMessage("Music Manager Access Code"),
    "restartApp" : MessageLookupByLibrary.simpleMessage("Please restart the app."),
    "title" : MessageLookupByLibrary.simpleMessage("MuTube")
  };
}
