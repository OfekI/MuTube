import 'package:equatable/equatable.dart';
import 'package:mutube/models/interfaces.dart';

class GoogleMusicCredentials extends Equatable {
  final OAuth2Credentials mobileClient, musicManager;

  GoogleMusicCredentials({this.mobileClient, this.musicManager});

  @override
  List<Object> get props => [mobileClient, musicManager];
}

class OAuth2Credentials with EquatableMixin implements JsonConvertable {
  final String accessToken,
      clientId,
      clientSecret,
      refreshToken,
      tokenUri,
      userAgent,
      revokeUri,
      tokenInfoUri,
      idTokenJWT;
  final int tokenExpiry;
  final List<String> scopes;
  final Map<String, dynamic> idToken, tokenResponse;

  OAuth2Credentials({
    this.accessToken,
    this.clientId,
    this.clientSecret,
    this.refreshToken,
    this.tokenExpiry,
    this.tokenUri,
    this.userAgent,
    this.revokeUri,
    this.idToken,
    this.tokenResponse,
    this.scopes,
    this.tokenInfoUri,
    this.idTokenJWT,
  });
  OAuth2Credentials.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'],
        clientId = json['clientId'],
        clientSecret = json['clientSecret'],
        refreshToken = json['refreshToken'],
        tokenExpiry = json['tokenExpiry'],
        tokenUri = json['tokenUri'],
        userAgent = json['userAgent'],
        revokeUri = json['revokeUri'],
        scopes = json['scopes'] != null
            ? <String>[for (var scope in json['scopes']) scope]
            : null,
        tokenInfoUri = json['tokenInfoUri'],
        idToken = json['idToken'] as Map<String, dynamic>,
        idTokenJWT = json['idTokenJWT'],
        tokenResponse = json['tokenResponse'] as Map<String, dynamic>;

  @override
  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'clientId': clientId,
        'clientSecret': clientSecret,
        'refreshToken': refreshToken,
        'tokenExpiry': tokenExpiry,
        'tokenUri': tokenUri,
        'userAgent': userAgent,
        'revokeUri': revokeUri,
        'scopes': scopes,
        'tokenInfoUri': tokenInfoUri,
        'idToken': idToken,
        'idTokenJWT': idTokenJWT,
        'tokenResponse': tokenResponse,
      };

  @override
  List<Object> get props => [
        accessToken,
        clientId,
        clientSecret,
        scopes,
        refreshToken,
        tokenExpiry,
        tokenUri,
        userAgent,
        revokeUri,
        tokenExpiry,
        idTokenJWT,
      ];
}
