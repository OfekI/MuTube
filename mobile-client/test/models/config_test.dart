import 'package:flutter_test/flutter_test.dart';
import 'package:mutube/models/config.dart';

void main() {
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

  test('AppConfig toJson should produce the correct input to fromJson', () {
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
    expect(config.toJson(), {
      'googleMusicOAuth': {
        'mobileClient': oAuthClientJson,
        'musicManager': {
          ...oAuthClientJson,
          'clientId': 'foo',
          'clientSecret': 'bar',
          'scope': 'bar.com/baz',
        }
      },
    });
    expect(AppConfig.fromJson(config.toJson()).toJson(), config.toJson());
  });
  test('GoogleMusicOAuth toJson should produce the correct input to fromJson',
      () {
    final GoogleMusicOAuth oAuth = GoogleMusicOAuth(
      mobileClient: GoogleMusicOAuthClient.fromJson(oAuthClientJson),
      musicManager: GoogleMusicOAuthClient.fromJson({
        ...oAuthClientJson,
        'clientId': 'foo',
        'clientSecret': 'bar',
        'scope': 'bar.com/baz',
      }),
    );
    expect(oAuth.toJson(), {
      'mobileClient': oAuthClientJson,
      'musicManager': {
        ...oAuthClientJson,
        'clientId': 'foo',
        'clientSecret': 'bar',
        'scope': 'bar.com/baz',
      },
    });
    expect(GoogleMusicOAuth.fromJson(oAuth.toJson()).toJson(), oAuth.toJson());
  });
  test('GoogleMusicOAuthClient should produce the correct input to fromJson',
      () {
    final oAuthClient = GoogleMusicOAuthClient.fromJson(oAuthClientJson);
    expect(oAuthClient.toJson(), oAuthClientJson);
    expect(GoogleMusicOAuthClient.fromJson(oAuthClient.toJson()).toJson(),
        oAuthClient.toJson());
  });
}
