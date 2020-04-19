import 'package:equatable/equatable.dart';
import 'package:mutube/models/interfaces.dart';

class AppConfig extends Equatable implements JsonConvertable {
  final GoogleMusicOAuth googleMusicOAuth;

  AppConfig({this.googleMusicOAuth});
  AppConfig.fromJson(Map<String, dynamic> json)
      : googleMusicOAuth = GoogleMusicOAuth.fromJson(
          json['googleMusicOAuth'] as Map<String, dynamic>,
        );

  @override
  Map<String, dynamic> toJson() => {
        'googleMusicOAuth': googleMusicOAuth.toJson(),
      };

  @override
  List<Object> get props => [googleMusicOAuth];
}

class GoogleMusicOAuth extends Equatable implements JsonConvertable {
  final GoogleMusicOAuthClient mobileClient;
  final GoogleMusicOAuthClient musicManager;

  GoogleMusicOAuth({this.mobileClient, this.musicManager});
  GoogleMusicOAuth.fromJson(Map<String, dynamic> json)
      : mobileClient = GoogleMusicOAuthClient.fromJson(
          json['mobileClient'] as Map<String, dynamic>,
        ),
        musicManager = GoogleMusicOAuthClient.fromJson(
          json['musicManager'] as Map<String, dynamic>,
        );

  @override
  Map<String, dynamic> toJson() => {
        'mobileClient': mobileClient.toJson(),
        'musicManager': musicManager.toJson(),
      };

  @override
  List<Object> get props => [mobileClient, musicManager];
}

class GoogleMusicOAuthClient extends Equatable implements JsonConvertable {
  final String _authAuthority,
      _authPath,
      clientId,
      clientSecret,
      redirectUri,
      scope,
      accessType,
      responseType,
      _revokeAuthority,
      _revokePath,
      _tokenAuthority,
      _tokenPath,
      _tokenInfoAuthority,
      _tokenInfoPath;

  GoogleMusicOAuthClient({
    authAuthority,
    authPath,
    this.clientId,
    this.clientSecret,
    this.redirectUri,
    this.scope,
    this.accessType,
    this.responseType,
    revokeAuthority,
    revokePath,
    tokenAuthority,
    tokenPath,
    tokenInfoAuthority,
    tokenInfoPath,
  })  : _revokeAuthority = revokeAuthority,
        _revokePath = revokePath,
        _authAuthority = authAuthority,
        _authPath = authPath,
        _tokenAuthority = tokenAuthority,
        _tokenPath = tokenPath,
        _tokenInfoAuthority = tokenInfoAuthority,
        _tokenInfoPath = tokenInfoPath;

  GoogleMusicOAuthClient.fromJson(Map<String, dynamic> json)
      : _authAuthority = json['authUrl']['authority'],
        _authPath = json['authUrl']['path'],
        clientId = json['clientId'],
        clientSecret = json['clientSecret'],
        scope = json['scope'],
        redirectUri = json['redirectUri'],
        accessType = json['accessType'],
        responseType = json['responseType'],
        _revokeAuthority = json['revokeUrl']['authority'],
        _revokePath = json['revokeUrl']['path'],
        _tokenAuthority = json['tokenUrl']['authority'],
        _tokenPath = json['tokenUrl']['path'],
        _tokenInfoAuthority = json['tokenInfoUrl']['authority'],
        _tokenInfoPath = json['tokenInfoUrl']['path'];

  Uri get authUrl => Uri.https(_authAuthority, _authPath, {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': scope,
        'access_type': accessType,
        'response_type': responseType,
      });

  Uri get revokeUrl => Uri.https(_revokeAuthority, _revokePath);
  Uri get tokenUrl => Uri.https(_tokenAuthority, _tokenPath);
  Uri get tokenInfoUrl => Uri.https(_tokenInfoAuthority, _tokenInfoPath);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'authUrl': {
          'authority': _authAuthority,
          'path': _authPath,
        },
        'clientId': clientId,
        'clientSecret': clientSecret,
        'redirectUri': redirectUri,
        'scope': scope,
        'accessType': accessType,
        'responseType': responseType,
        'revokeUrl': {
          'authority': _revokeAuthority,
          'path': _revokePath,
        },
        'tokenUrl': {
          'authority': _tokenAuthority,
          'path': _tokenPath,
        },
        'tokenInfoUrl': {
          'authority': _tokenInfoAuthority,
          'path': _tokenInfoPath,
        },
      };

  @override
  List<Object> get props => [
        accessType,
        clientId,
        clientSecret,
        redirectUri,
        responseType,
        scope,
        _authAuthority,
        _authPath,
        _revokeAuthority,
        _revokePath,
        _tokenAuthority,
        _tokenPath,
        _tokenInfoAuthority,
        _tokenInfoPath,
      ];
}
