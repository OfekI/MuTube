import json

from pytest import fixture
from werkzeug.datastructures import Headers

from music_service.db import get_db


class CallRecorder:
    called = False

    def function(self, *args, **kwargs):
        self.called = True


def test_connection_is_idempotent(app):
    with app.app_context():
        assert get_db() is get_db()


def test_connection_logs_in(app, monkeypatch):
    mobile_client_recorder = CallRecorder()
    music_manager_recorder = CallRecorder()

    monkeypatch.setattr("gmusicapi.Mobileclient.is_authenticated", lambda self: False)
    monkeypatch.setattr("gmusicapi.Musicmanager.is_authenticated", lambda self: False)
    monkeypatch.setattr(
        "gmusicapi.Mobileclient.oauth_login", mobile_client_recorder.function
    )
    monkeypatch.setattr("gmusicapi.Musicmanager.login", music_manager_recorder.function)

    cred = json.dumps(
        {
            "accessToken": "",
            "clientId": "",
            "clientSecret": "",
            "refreshToken": "",
            "tokenExpiry": 0,
            "tokenUri": "",
            "userAgent": "",
        }
    )
    with app.test_request_context(
        headers=Headers(
            {"Mobile-Client-Authorization": cred, "Music-Manager-Authorization": cred}
        )
    ):
        get_db()

        assert mobile_client_recorder.called
        assert music_manager_recorder.called


def test_get_songs_returns_songs(app, monkeypatch):
    monkeypatch.setattr(
        "gmusicapi.Mobileclient.get_all_songs", lambda self: [{"id": 1}]
    )
    with app.app_context():
        assert get_db().get_songs() == [{"id": 1}]


def test_get_songs_is_idempotent(app, monkeypatch):
    monkeypatch.setattr(
        "gmusicapi.Mobileclient.get_all_songs", lambda self: [{"id": 1}]
    )
    with app.app_context():
        assert get_db().get_songs() is get_db().get_songs()


def test_connection_closes_after_request(app, monkeypatch):
    mobile_client_recorder = CallRecorder()
    music_manager_recorder = CallRecorder()

    with app.app_context():
        db = get_db()

        # Have to patch these methods after initializing the clients
        # because :__init__ calls :logout for Mobileclient and Musicmanager
        monkeypatch.setattr(
            "gmusicapi.Mobileclient.logout", mobile_client_recorder.function
        )
        monkeypatch.setattr(
            "gmusicapi.Musicmanager.logout", music_manager_recorder.function
        )

        assert not mobile_client_recorder.called
        assert not music_manager_recorder.called

    assert mobile_client_recorder.called
    assert music_manager_recorder.called
