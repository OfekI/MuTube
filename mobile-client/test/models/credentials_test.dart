import 'package:flutter_test/flutter_test.dart';
import 'package:mutube/models/credentials.dart';

void main() {
  test('OAuth2Credentials toJson should produce the correct input to fromJson',
      () {
    final Map<String, dynamic> json = {
      'accessToken': 'foo',
      'clientId': 'bar',
      'clientSecret': 'baz',
      'refreshToken': 'quux',
      'tokenExpiry': 10,
      'tokenUri': 'foo:bar',
      'userAgent': 'grault',
      'revokeUri': 'bar:baz',
      'scopes': ['baz:quux'],
      'tokenInfoUri': 'quux:corge',
      'idToken': {'foo': 'bar'},
      'idTokenJWT': 'foo.bar.baz',
      'tokenResponse': {'bar': 'baz'},
    };
    final credentials = OAuth2Credentials.fromJson(json);

    expect(credentials.toJson(), json);
    expect(
      OAuth2Credentials.fromJson(credentials.toJson()).toJson(),
      credentials.toJson(),
    );
  });
}
