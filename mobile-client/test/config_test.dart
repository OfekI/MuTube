import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mutube/config.dart';
import 'package:mutube/models/config.dart';

void main() {
  group('ConfigUtils', () {
    group('updateJson', () {
      test('should start with base values and update update values', () {
        final actual = ConfigUtils.mergeJson(base: {
          'baseKey': 'baseValue',
          'numberKey': 1,
          'stringKey': 'value1',
          'booleanKey': false,
          'nullKey': null,
          'listKey': [1],
        }, update: {
          'updateKey': 'updateValue',
          'numberKey': 2,
          'stringKey': 'value2',
          'booleanKey': true,
          'nullKey': {},
          'listKey': [2],
        });
        expect(actual, {
          'baseKey': 'baseValue',
          'updateKey': 'updateValue',
          'numberKey': 2,
          'stringKey': 'value2',
          'booleanKey': true,
          'nullKey': {},
          'listKey': [2],
        });
      });
      test('should work recursively on nested maps', () {
        final actual = ConfigUtils.mergeJson(base: {
          'objectKey': {
            'nestedBaseKey': 'nestedBaseValue',
            'nestedStringKey': 'nestedStringValue1',
          },
        }, update: {
          'objectKey': {
            'nestedUpdateKey': 'nestedUpdateValue',
            'nestedStringKey': 'nestedStringValue2',
          },
        });

        expect(actual, {
          'objectKey': {
            'nestedBaseKey': 'nestedBaseValue',
            'nestedUpdateKey': 'nestedUpdateValue',
            'nestedStringKey': 'nestedStringValue2',
          },
        });
      });
    });
    group('parseConfig', () {
      test('should include base config for all values', () {
        final actual = ConfigUtils.parseConfig({
          'base': {
            'foo': 'bar',
            'bar': {
              'base': {'foo': 'bar'},
              'bar': <String, dynamic>{}
            },
          },
          'specific1': {'foo': 'baz', 'baz': 'quux'},
          'specific2': <String, dynamic>{},
          'foo': 'bar',
        });
        expect(actual, {
          'specific1': {
            'foo': 'baz',
            'bar': {
              'bar': {'foo': 'bar'},
            },
            'baz': 'quux',
          },
          'specific2': {
            'foo': 'bar',
            'bar': {
              'bar': {'foo': 'bar'},
            },
          },
          'foo': 'bar',
        });
      });
      test(
        "should throw ArgumentError if json['base'] is not an object",
        () => expect(
          () => ConfigUtils.parseConfig({'base': 'value'}),
          throwsArgumentError,
        ),
      );
    });
    group('forEnvironment', () {
      test("should return the correct dev configuration", () async {
        final testConfig = {
          'base': {
            'googleMusicOAuth': {
              'base': {
                'authUrl': {'authority': 'foo.com', 'path': 'bar'},
                'redirectUri': 'quux',
                'accessType': 'grault',
                'responseType': 'garply',
                'base': {'authority': 'bar.com'},
                'revokeUrl': {'path': 'baz'},
                'tokenUrl': {'path': 'quux'},
                'tokenInfoUrl': {'path': 'corge'},
              },
              'mobileClient': {
                'clientId': 'baz',
                'clientSecret': 'corge',
                'scope': 'grault',
              },
              'musicManager': {
                'clientId': 'quux',
                'clientSecret': 'garply',
                'scope': 'plugh',
              },
            },
          },
        };
        final actual =
            await ConfigUtils.forEnvironment('test', jsonEncode(testConfig));
        final expected = AppConfig(
          googleMusicOAuth: GoogleMusicOAuth(
            mobileClient: GoogleMusicOAuthClient(
              authAuthority: 'foo.com',
              authPath: 'bar',
              redirectUri: 'quux',
              accessType: 'grault',
              responseType: 'garply',
              revokeAuthority: 'bar.com',
              revokePath: 'baz',
              tokenAuthority: 'bar.com',
              tokenPath: 'quux',
              tokenInfoAuthority: 'bar.com',
              tokenInfoPath: 'corge',
              clientId: 'baz',
              clientSecret: 'corge',
              scope: 'grault',
            ),
            musicManager: GoogleMusicOAuthClient(
              authAuthority: 'foo.com',
              authPath: 'bar',
              redirectUri: 'quux',
              accessType: 'grault',
              responseType: 'garply',
              revokeAuthority: 'bar.com',
              revokePath: 'baz',
              tokenAuthority: 'bar.com',
              tokenPath: 'quux',
              tokenInfoAuthority: 'bar.com',
              tokenInfoPath: 'corge',
              clientId: 'quux',
              clientSecret: 'garply',
              scope: 'plugh',
            ),
          ),
        );
        expect(actual, expected);
      });
    });
  });
}
