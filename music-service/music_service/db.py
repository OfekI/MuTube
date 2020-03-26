from os import path
import gmusicapi
from flask import current_app, g


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

        self._store_credentials()
        self._login()

    def _store_credentials(self):
        if self.mobile_credentials is not None:
            if not path.exists(self.mobile_credentials):
                gmusicapi.Mobileclient.perform_oauth(
                    storage_filepath=self.mobile_credentials
                )
        elif not path.exists(gmusicapi.Mobileclient.OAUTH_FILEPATH):
            gmusicapi.Mobileclient.perform_oauth()

        if self.manager_credentials is not None:
            if not path.exists(self.manager_credentials):
                gmusicapi.Musicmanager.perform_oauth(
                    storage_filepath=self.manager_credentials
                )
        elif not path.exists(gmusicapi.Musicmanager.OAUTH_FILEPATH):
            gmusicapi.Musicmanager.perform_oauth()

    def _login(self):
        if self.mobile_credentials is not None:
            if not self.mobile_client.is_authenticated():
                self.mobile_client.oauth_login(
                    self.device_id, oauth_credentials=self.mobile_credentials
                )
        elif not self.mobile_client.is_authenticated():
            self.mobile_client.oauth_login(self.device_id)

        if self.manager_credentials is not None:
            if not self.music_manager.is_authenticated():
                self.music_manager.login(
                    uploader_id=self.uploader_id,
                    uploader_name=self.uploader_name,
                    oauth_credentials=self.manager_credentials,
                )
        elif not self.music_manager.is_authenticated():
            self.music_manager.login(
                uploader_id=self.uploader_id, uploader_name=self.uploader_name
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
        g.db = GoogleMusicDatabase(
            device_id=current_app.config["DEVICE_ID"],
            mobile_credentials=current_app.config.get("MOBILE_CREDENTIALS", None),
            uploader_id=current_app.config.get("UPLOADER_ID", None),
            uploader_name=current_app.config.get("UPLOADER_NAME", None),
            manager_credentials=current_app.config.get("MANAGER_CREDENTIALS", None),
        )

    return g.db


def close_db(e=None):
    db = g.pop("db", None)

    if db is not None:
        db.close()


def init_app(app):
    app.teardown_appcontext(close_db)
