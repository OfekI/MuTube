import json
from os import path

import gmusicapi
import oauth2client
from flask import current_app, g, request


class GoogleMusicDatabase:
    def __init__(
        self,
        device_id,
        mobile_credentials=None,
        uploader_id=None,
        uploader_name=None,
        manager_credentials=None,
    ):
        self.device_id = device_id
        self.mobile_credentials = mobile_credentials

        self.uploader_id = uploader_id
        self.uploader_name = uploader_name
        self.manager_credentials = manager_credentials

        self.mobile_client = gmusicapi.Mobileclient()
        self.music_manager = gmusicapi.Musicmanager()

        self._login()

    def _login(self):
        if self.mobile_credentials is not None:
            if not self.mobile_client.is_authenticated():
                self.mobile_client.oauth_login(
                    self.device_id, oauth_credentials=self.mobile_credentials
                )

        if self.manager_credentials is not None:
            if not self.music_manager.is_authenticated():
                self.music_manager.login(
                    uploader_id=self.uploader_id,
                    uploader_name=self.uploader_name,
                    oauth_credentials=self.manager_credentials,
                )

    def is_authenticated(self):
        return (
            self.mobile_client.is_authenticated()
            and self.music_manager.is_authenticated()
        )

    def get_songs(self):
        if getattr(self, "songs", None) is None:
            self.songs = self.mobile_client.get_all_songs()

        return self.songs

    def close(self):
        self.mobile_client.logout()
        self.music_manager.logout()


def get_db():
    if "db" not in g:
        mobile_credentials = (
            json_to_credentials(
                json.loads(request.headers["Mobile-Client-Authorization"])
            )
            if "Mobile-Client-Authorization" in request.headers
            else None
        )
        manager_credentials = (
            json_to_credentials(
                json.loads(request.headers["Music-Manager-Authorization"])
            )
            if "Music-Manager-Authorization" in request.headers
            else None
        )
        g.db = GoogleMusicDatabase(
            device_id=current_app.config["DEVICE_ID"],
            mobile_credentials=mobile_credentials,
            uploader_id=current_app.config.get("UPLOADER_ID", None),
            uploader_name=current_app.config.get("UPLOADER_NAME", None),
            manager_credentials=manager_credentials,
        )

    return g.db


def close_db(e=None):
    db = g.pop("db", None)

    if db is not None:
        db.close()


def init_app(app):
    app.teardown_appcontext(close_db)


def json_to_credentials(json):
    return oauth2client.client.OAuth2Credentials(
        access_token=json["accessToken"],
        client_id=json["clientId"],
        client_secret=json["clientSecret"],
        refresh_token=json["refreshToken"],
        token_expiry=json["tokenExpiry"],
        token_uri=json["tokenUri"],
        user_agent=json["userAgent"],
    )
