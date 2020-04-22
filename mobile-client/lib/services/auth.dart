import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mutube/models/models.dart';
import 'package:optional/optional.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  static const mobileClientCredentialsKey = "MOBILE_CLIENT_CREDENTIALS";
  static const musicManagerCredentialsKey = "MUSIC_MANAGER_CREDENTIALS";

  void obtainAccessCode(
    GoogleMusicOAuthClient client, {
    void Function(String) launch = launch,
  }) {
    launch(client.authUrl.toString());
  }

  static OAuth2Credentials _buildCredential(
    GoogleMusicOAuthClient client,
    Map<String, dynamic> responseBody,
  ) =>
      OAuth2Credentials(
        accessToken: responseBody['access_token'],
        clientId: client.clientId,
        clientSecret: client.clientSecret,
        refreshToken: responseBody['refresh_token'],
        tokenExpiry: DateTime.now()
            .toUtc()
            .add(Duration(seconds: responseBody['expires_in']))
            .millisecondsSinceEpoch,
        tokenUri: client.tokenUrl.toString(),
        revokeUri: client.revokeUrl.toString(),
        tokenResponse: responseBody,
        scopes: [client.scope],
        tokenInfoUri: client.tokenInfoUrl.toString(),
      );

  Future<Optional<OAuth2Credentials>> getCredentials(
    GoogleMusicOAuthClient client,
    String code, {
    Future<http.Response> Function(Uri, {Map<String, dynamic> body}) post =
        http.post,
  }) async {
    final tokenUrl = client.tokenUrl;

    http.Response resp = await post(tokenUrl, body: {
      'client_id': client.clientId,
      'code': code,
      'scope': client.scope,
      'client_secret': client.clientSecret,
      'grant_type': 'authorization_code',
      'redirect_uri': client.redirectUri,
    });

    if (resp.statusCode == 200) {
      final content = jsonDecode(resp.body) as Map<String, dynamic>;
      if (content['access_token'] != null) {
        return Optional.of(_buildCredential(client, content));
      }
    }
    return Optional.empty();
  }

  static Future<void> Function(OAuth2Credentials) _saveCredentials(
    String key,
    StreamController<OAuth2Credentials> stream,
  ) =>
      (OAuth2Credentials credentials) async {
        final value = Optional.ofNullable(credentials)
            .map((creds) => creds.toJson())
            .map(jsonEncode)
            .orElse(null);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString(key, value);
        stream.add(credentials);
      };

  final StreamController<OAuth2Credentials> _mobileClientCredentials =
      StreamController.broadcast();
  final StreamController<OAuth2Credentials> _musicManagerCredentials =
      StreamController.broadcast();

  AuthService() {
    _init();
  }

  AuthService.withError() {
    _initWithError();
  }

  AuthService.withNoData();

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _musicManagerCredentials.add(null);
    final mobileClient =
        Optional.ofNullable(prefs.getString(mobileClientCredentialsKey))
            .map(jsonDecode)
            .map((json) => OAuth2Credentials.fromJson(json))
            .orElse(null);
    final musicManager =
        Optional.ofNullable(prefs.getString(musicManagerCredentialsKey))
            .map(jsonDecode)
            .map((json) => OAuth2Credentials.fromJson(json))
            .orElse(null);

    _mobileClientCredentials.add(mobileClient);
    _musicManagerCredentials.add(musicManager);
  }

  Future<void> _initWithError() async {
    await SharedPreferences.getInstance();
    _mobileClientCredentials.addError('error');
  }

  Stream<GoogleMusicCredentials> get credentials =>
      _mobileClientCredentials.stream
          .combineLatest<OAuth2Credentials, GoogleMusicCredentials>(
            _musicManagerCredentials.stream,
            (mobileClient, musicManager) => GoogleMusicCredentials(
              mobileClient: mobileClient,
              musicManager: musicManager,
            ),
          )
          .debounce(Duration(milliseconds: 10));

  Future<void> Function(OAuth2Credentials) get saveMobileClientCredentials =>
      _saveCredentials(
        AuthService.mobileClientCredentialsKey,
        _mobileClientCredentials,
      );

  Future<void> Function(OAuth2Credentials) get saveMusicManagerCredentials =>
      _saveCredentials(
        AuthService.musicManagerCredentialsKey,
        _musicManagerCredentials,
      );

  void logOut() {
    saveMobileClientCredentials(null);
    saveMusicManagerCredentials(null);
  }

  void dispose() {
    _mobileClientCredentials.close();
    _musicManagerCredentials.close();
  }
}
