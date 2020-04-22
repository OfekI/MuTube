import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mutube/services/services.dart';
import 'package:mutube/models/models.dart';
import 'package:optional/optional.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class _AuthServiceDependency {
  void launch(String url);
  Future<http.Response> post(Uri url, {Map<String, dynamic> body});
}

class _MockDependency extends Mock implements _AuthServiceDependency {}

void main() {
  group('AuthService', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final configFuture = ConfigUtils.forEnvironment('test');
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

    group('init', () {
      test('should be unauthenticated if no stored credentials', () {
        SharedPreferences.setMockInitialValues({});
        final auth = AuthService();
        expect(auth.credentials, emits(GoogleMusicCredentials()));
      });
      test('should emit mobileClient credentials if present', () {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
        });
        final auth = AuthService();
        expect(
          auth.credentials,
          emits(GoogleMusicCredentials(mobileClient: credential)),
        );
      });
      test('should emit musicManager credentials if present', () {
        SharedPreferences.setMockInitialValues({
          AuthService.musicManagerCredentialsKey:
              jsonEncode(credential.toJson()),
        });
        final auth = AuthService();
        expect(
          auth.credentials,
          emits(GoogleMusicCredentials(musicManager: credential)),
        );
      });
      test('should emit credentials if present', () {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
          AuthService.musicManagerCredentialsKey:
              jsonEncode(credential.toJson()),
        });
        final auth = AuthService();
        expect(
          auth.credentials,
          emits(GoogleMusicCredentials(
            mobileClient: credential,
            musicManager: credential,
          )),
        );
      });
    });
    group('obtainAccessCode', () {
      test('should launch authUrl', () async {
        final config = await configFuture;
        final mock = _MockDependency();

        AuthService().obtainAccessCode(
          config.googleMusicOAuth.mobileClient,
          launch: mock.launch,
        );
        verify(
          mock.launch(config.googleMusicOAuth.mobileClient.authUrl.toString()),
        ).called(1);

        AuthService().obtainAccessCode(
          config.googleMusicOAuth.musicManager,
          launch: mock.launch,
        );
        verify(
          mock.launch(config.googleMusicOAuth.musicManager.authUrl.toString()),
        ).called(1);
      });
    });
    group('getCredentials', () {
      test('should return credentials from request body', () async {
        final config = await configFuture;
        final mock = _MockDependency();

        final response = http.Response(
          jsonEncode({'access_token': 'bar', 'expires_in': 10}),
          200,
        );

        when(mock.post(
          config.googleMusicOAuth.mobileClient.tokenUrl,
          body: anyNamed('body'),
        )).thenAnswer((_) async => response);

        final credentials = await AuthService().getCredentials(
          config.googleMusicOAuth.mobileClient,
          'foo',
          post: mock.post,
        );

        expect(credentials.isPresent, true);
        expect(credentials.value.accessToken, 'bar');
      });
      test('should return empty optional if request unsuccessful', () async {
        final config = await configFuture;
        final mock = _MockDependency();

        final response = http.Response('', 500);

        when(mock.post(
          config.googleMusicOAuth.mobileClient.tokenUrl,
          body: anyNamed('body'),
        )).thenAnswer((_) async => response);

        final credentials = await AuthService().getCredentials(
          config.googleMusicOAuth.mobileClient,
          'foo',
          post: mock.post,
        );

        expect(credentials.isEmpty, true);
      });
    });
    group('saveMobileClientCredentials', () {
      test('should persist credentials', () async {
        SharedPreferences.setMockInitialValues({});
        final auth = AuthService();
        auth.saveMobileClientCredentials(credential);

        final prefs = await SharedPreferences.getInstance();
        expect(
          Optional.ofNullable(
                  prefs.getString(AuthService.mobileClientCredentialsKey))
              .map(jsonDecode)
              .map((json) => OAuth2Credentials.fromJson(json))
              .orElse(null),
          credential,
        );
      });
      test('should emit credentials', () {
        SharedPreferences.setMockInitialValues({});
        final auth = AuthService();
        auth.saveMobileClientCredentials(credential);

        expect(
          auth.credentials,
          emits(GoogleMusicCredentials(mobileClient: credential)),
        );
      });
    });
    group('saveMusicManagerCredentials', () {
      test('should persist credentials', () async {
        SharedPreferences.setMockInitialValues({});
        final auth = AuthService();
        auth.saveMusicManagerCredentials(credential);

        final prefs = await SharedPreferences.getInstance();
        expect(
          Optional.ofNullable(
                  prefs.getString(AuthService.musicManagerCredentialsKey))
              .map(jsonDecode)
              .map((json) => OAuth2Credentials.fromJson(json))
              .orElse(null),
          credential,
        );
      });
      test('should emit credentials', () {
        SharedPreferences.setMockInitialValues({});
        final auth = AuthService();
        auth.saveMusicManagerCredentials(credential);

        expect(
          auth.credentials,
          emits(GoogleMusicCredentials(musicManager: credential)),
        );
      });
    });
    group('logOut', () {
      test('should delete stored credentials', () async {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
          AuthService.musicManagerCredentialsKey:
              jsonEncode(credential.toJson()),
        });

        final auth = AuthService();
        auth.logOut();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(AuthService.mobileClientCredentialsKey), null);
        expect(prefs.getString(AuthService.musicManagerCredentialsKey), null);
      });
      test('should emit null credentials', () {
        SharedPreferences.setMockInitialValues({
          AuthService.mobileClientCredentialsKey:
              jsonEncode(credential.toJson()),
          AuthService.musicManagerCredentialsKey:
              jsonEncode(credential.toJson()),
        });

        final auth = AuthService();
        auth.logOut();

        expect(auth.credentials, emits(GoogleMusicCredentials()));
      });
    });
  });
}
