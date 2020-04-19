import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mutube/models/models.dart';
import 'package:optional/optional.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:url_launcher/url_launcher.dart';

// enum AuthenticationStatus {
//   UNAUTHENTICATED,
//   AWAITING_MOBILE_CLIENT_CODE,
//   AWAITING_MUSIC_MANAGER_CODE,
//   AUTHENTICATED,
// }

// @immutable
// class LoginFlowStep extends Equatable {
//   final AuthenticationStatus status;
//   const LoginFlowStep({this.status});

//   @override
//   List<Object> get props => [status];
// }

// @immutable
// class AuthenticatedStep extends LoginFlowStep {
//   @override
//   final status = AuthenticationStatus.AUTHENTICATED;
//   final GoogleMusicCredentials data;

//   const AuthenticatedStep({this.data});

//   @override
//   List<Object> get props => [status, data];
// }

class AuthService {
  static const mobileClientCredentialsKey = "MOBILE_CLIENT_CREDENTIALS";
  static const musicManagerCredentialsKey = "MUSIC_MANAGER_CREDENTIALS";

  static void obtainAccessCode(
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

  static Future<Optional<OAuth2Credentials>> getCredentials(
    GoogleMusicOAuthClient client,
    String code, {
    Future<http.Response> Function(Uri, {Map<String, dynamic> body}) post,
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

// class _AuthServiceState extends State<AuthService> {
//   final StreamController<LoginFlowStep> _loginFlow =
//       StreamController<LoginFlowStep>.broadcast();

//   Stream<LoginFlowStep> get loginFlow => _loginFlow.stream;

//   _AuthServiceState() {
//     _init();
//   }

//   void _init({void Function(String) launch = launch}) async {
//     final prefs = await SharedPreferences.getInstance();
//     final credentials = _getStoredCredentials(
//             AuthService.mobileClientCredentialsKey, prefs)
//         .flatMap((mobileClientCredentials) =>
//             _getStoredCredentials(AuthService.musicManagerCredentialsKey, prefs)
//                 .map((musicManagerCredentials) => GoogleMusicOAuthCredentials(
//                       mobileClient: mobileClientCredentials,
//                       musicManager: musicManagerCredentials,
//                     )));

//     if (credentials.isPresent) {
//       _loginFlow.add(AuthenticatedStep(
//         data: credentials.value,
//       ));
//     } else {
//       _loginFlow.add(LoginFlowStep(
//         status: AuthenticationStatus.UNAUTHENTICATED,
//       ));
//     }
//   }

//   Optional<OAuth2Credentials> _getStoredCredentials(
//           String key, SharedPreferences prefs) =>
//       Optional.ofNullable(prefs.getString(key))
//           .map(jsonDecode)
//           .map((json) => OAuth2Credentials.fromJson(json));

//   void _storeCredentials(String key, OAuth2Credentials credentials) async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString(key, jsonEncode(credentials.toJson()));
//   }

//   Future<Optional<OAuth2Credentials>> _requestCredentials(
//     GoogleMusicOAuthClient client,
//     String code, {
//     Future<http.Response> Function(
//       Uri, {
//       Map<String, dynamic> body,
//     })
//         post = http.post,
//   }) async {
//     final tokenUrl = client.tokenUrl;

//     http.Response resp = await post(tokenUrl, body: {
//       'client_id': client.clientId,
//       'code': code,
//       'scope': client.scope,
//       'client_secret': client.clientSecret,
//       'grant_type': 'authorization_code',
//       'redirect_uri': client.redirectUri,
//     });

//     if (resp.statusCode == 200) {
//       final content = jsonDecode(resp.body) as Map<String, dynamic>;
//       if (content['access_token'] != null) {
//         final accessToken = content['access_token'];
//         final refreshToken = content['refresh_token'];
//         final tokenExpiry = DateTime.now()
//             .toUtc()
//             .add(Duration(seconds: content['expires_in']));

//         return Optional.of(OAuth2Credentials(
//           accessToken: accessToken,
//           clientId: client.clientId,
//           clientSecret: client.clientSecret,
//           refreshToken: refreshToken,
//           tokenExpiry: tokenExpiry.millisecondsSinceEpoch.toString(),
//           tokenUri: tokenUrl.toString(),
//           revokeUri: client.revokeUrl.toString(),
//           tokenResponse: content,
//           scopes: [client.scope],
//           tokenInfoUri: client.tokenInfoUrl.toString(),
//         ));
//       }
//     }
//     return Optional.empty();
//   }

//   void stepOneGetMobileClientCode(
//     GoogleMusicOAuth googleMusicOAuth, {
//     void Function(String) launch = launch,
//   }) {
//     _loginFlow.add(LoginFlowStep(
//       status: AuthenticationStatus.AWAITING_MOBILE_CLIENT_CODE,
//     ));
//     launch(googleMusicOAuth.mobileClient.authUrl.toString());
//   }

//   void stepTwoGetMusicManagerCode(
//     GoogleMusicOAuth googleMusicOAuth,
//     String mobileClientCode, {
//     void Function(String) launch = launch,
//     Future<http.Response> Function(
//       Uri, {
//       Map<String, dynamic> body,
//     })
//         post = http.post,
//   }) async {
//     final mobileClientCredentials = await _requestCredentials(
//       googleMusicOAuth.mobileClient,
//       mobileClientCode,
//       post: post,
//     );

//     if (mobileClientCredentials.isPresent) {
//       _storeCredentials(
//         AuthService.mobileClientCredentialsKey,
//         mobileClientCredentials.value,
//       );

//       _loginFlow.add(LoginFlowStep(
//         status: AuthenticationStatus.AWAITING_MUSIC_MANAGER_CODE,
//       ));

//       launch(googleMusicOAuth.musicManager.authUrl.toString());
//     } else {
//       _loginFlow.add(LoginFlowStep(
//         status: AuthenticationStatus.UNAUTHENTICATED,
//       ));
//     }
//   }

//   void stepThreeFinishLogin(
//     GoogleMusicOAuth googleMusicOAuth,
//     String musicManagerCode, {
//     Future<http.Response> Function(
//       Uri, {
//       Map<String, dynamic> body,
//     })
//         post = http.post,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final musicManagerCredentials = await _requestCredentials(
//       googleMusicOAuth.musicManager,
//       musicManagerCode,
//       post: post,
//     );

//     if (musicManagerCredentials.isPresent) {
//       _storeCredentials(
//         AuthService.mobileClientCredentialsKey,
//         musicManagerCredentials.value,
//       );
//     }

//     final mobileClientCredentials = musicManagerCredentials.flatMap((_) =>
//         _getStoredCredentials(AuthService.mobileClientCredentialsKey, prefs));

//     if (mobileClientCredentials.isPresent) {
//       _loginFlow.add(AuthenticatedStep(
//         data: GoogleMusicOAuthCredentials(
//           mobileClient: mobileClientCredentials.value,
//           musicManager: musicManagerCredentials.value,
//         ),
//       ));
//     } else {
//       _loginFlow.add(LoginFlowStep(
//         status: AuthenticationStatus.UNAUTHENTICATED,
//       ));
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) => widget.child;

//   @override
//   void dispose() {
//     _loginFlow.close();
//     super.dispose();
//   }
// }

// class AuthService {
//   static const mobileClientCredentialsKey = "MOBILE_CLIENT_CREDENTIALS";
//   static const musicManagerCredentialsKey = "MUSIC_MANAGER_CREDENTIALS";

//   final _loginFlow = StreamController<LoginFlowStep>.broadcast();
//   final _credentials =
//       StreamController<GoogleMusicOAuthCredentials>.broadcast();

//   Stream<LoginFlowStep> get loginFlow => _loginFlow.stream;
//   Stream<GoogleMusicOAuthCredentials> get credentials => _credentials.stream;

//   AuthService() {
//     _loginFlow.add(LoginFlowStep.UNAUTHENTICATED);
//   }

//   void login(AppConfig config,
//       [Future<bool> Function(String) launch = launch]) async {
//     if (mobileClientCredentials != null && musicManagerCredentials != null) {
//       final credentials = GoogleMusicOAuthCredentials(
//         mobileClient: OAuth2Credentials.fromJson(
//           jsonDecode(mobileClientCredentials),
//         ),
//         musicManager: OAuth2Credentials.fromJson(
//           jsonDecode(musicManagerCredentials),
//         ),
//       );
//       _credentials.add(credentials);
//       _loginFlow.add(LoginFlowStep.AUTHENTICATED);
//     } else if (mobileClientCredentials != null) {
//       _awaitingAccessCode.add(event);
//     } else {
//       _awaitingAccessCode.add(true);
//       launchAuthorizeUrl(config, launch);
//     }
//   }

//   Future<Optional<GoogleMusicOAuthCredentials>> getStoredCredentials() async {
//     final prefs = await SharedPreferences.getInstance();
//     final Optional<OAuth2Credentials> mobileClientCredentials =
//         Optional.ofNullable(prefs.getString(mobileClientCredentialsKey))
//             .map(jsonDecode)
//             .map((json) => OAuth2Credentials.fromJson(json));
//     final Optional<OAuth2Credentials> musicManagerCredentials =
//         Optional.ofNullable(prefs.getString(musicManagerCredentialsKey))
//             .map(jsonDecode)
//             .map((json) => OAuth2Credentials.fromJson(json));

//     return mobileClientCredentials.flatMap(
//       (mobileClient) => musicManagerCredentials
//           .map((musicManager) => GoogleMusicOAuthCredentials(
//                 mobileClient: mobileClient,
//                 musicManager: musicManager,
//               )),
//     );
//   }

//   void submitAccessCode(BuildContext context, String code) async {
//     _awaitingAccessCode.add(false);

//     final credentials = await requestAccessToken(context, code);

//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString(
//       mobileClientCredentialsKey,
//       jsonEncode(credentials.toJson()),
//     );

//     _credentials.add(credentials);
//   }

//   void logOut() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.remove(mobileClientCredentialsKey);
//     _credentials.add(null);
//   }

//   void launchAuthorizeUrl(AppConfig config,
//       [Future<bool> Function(String) launch = launch]) {
//     final authUrl = config.googleMusicOAuth.mobileClient.authUrl;
//     launch(authUrl.toString());
//   }

//   Future<OAuth2Credentials> requestAccessToken(
//       BuildContext context, String code) async {
//     final GoogleMusicOAuthClient mobileClient =
//         Provider.of<AppConfig>(context, listen: false)
//             .googleMusicOAuth
//             .mobileClient;
//     final tokenUrl = mobileClient.tokenUrl;

//     http.Response resp = await http.post(tokenUrl, body: {
//       'client_id': mobileClient.clientId,
//       'code': code,
//       'scope': mobileClient.scope,
//       'client_secret': mobileClient.clientSecret,
//       'grant_type': 'authorization_code',
//       'redirect_uri': mobileClient.redirectUri,
//     });

//     if (resp.statusCode == 200) {
//       final content = jsonDecode(resp.body) as Map<String, dynamic>;
//       if (content['access_token'] != null) {
//         final accessToken = content['access_token'];
//         final refreshToken = content['refresh_token'];
//         final tokenExpiry = DateTime.now()
//             .toUtc()
//             .add(Duration(seconds: content['expires_in']));

//         return OAuth2Credentials(
//           accessToken: accessToken,
//           clientId: mobileClient.clientId,
//           clientSecret: mobileClient.clientSecret,
//           refreshToken: refreshToken,
//           tokenExpiry: tokenExpiry.millisecondsSinceEpoch.toString(),
//           tokenUri: tokenUrl.toString(),
//           revokeUri: mobileClient.revokeUrl.toString(),
//           tokenResponse: content,
//           scopes: [mobileClient.scope],
//           tokenInfoUri: mobileClient.tokenInfoUrl.toString(),
//         );
//       }
//     }

//     return null;
//   }

//   void close() {
//     _awaitingAccessCode.close();
//     _credentials.close();
//   }
// }
