from os import path

from pytest import fixture

from music_service import create_app


class GoogleMusicClientMock:
    @staticmethod
    def perform_oauth(*args, **kwargs):
        pass

    def is_authenticated(self):
        return True

    def logout(self):
        pass


class MobileclientMock(GoogleMusicClientMock):
    def oauth_login(self, *args, **kwargs):
        pass

    def get_all_songs(self):
        return None


class MusicmanagerMock(GoogleMusicClientMock):
    def login(self, *args, **kwargs):
        pass


@fixture
def app(monkeypatch):
    app = create_app(
        {
            "TESTING": True,
            "MOBILE_CREDENTIALS": path.join(
                path.dirname(__file__), "mobile_credentials.cred"
            ),
            "MANAGER_CREDENTIALS": path.join(
                path.dirname(__file__), "manager_credentials.cred"
            ),
            "UPLOADER_ID": "8E:2F:A7:F3:DC:27",
            "UPLOADER_NAME": "Test Device",
        }
    )

    monkeypatch.setattr("gmusicapi.Mobileclient", MobileclientMock)
    monkeypatch.setattr("gmusicapi.Musicmanager", MusicmanagerMock)

    return app
