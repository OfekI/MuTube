import json
from collections import Counter

import graphene

from . import db


class Song(graphene.ObjectType):
    id = graphene.NonNull(graphene.ID)
    title = graphene.NonNull(graphene.String)
    artist = graphene.Field(lambda: Artist)
    year = graphene.Int()
    album = graphene.Field(lambda: Album)
    trackNumber = graphene.NonNull(graphene.Int, default_value=1)
    discNumber = graphene.NonNull(graphene.Int, default_value=0)

    @staticmethod
    def resolve_artist(parent, info):
        if "artist" in parent and parent["artist"] != "":
            return {"name": parent["artist"]}
        else:
            return None

    @staticmethod
    def resolve_album(parent, info):
        if "album" in parent and parent["album"] != "":
            return {"name": parent["album"]}
        else:
            return None


class Album(graphene.ObjectType):
    name = graphene.NonNull(graphene.String)
    artist = graphene.Field(lambda: Artist)
    tracks = graphene.NonNull(graphene.List(lambda: graphene.NonNull(Song)))
    total_track_count = graphene.NonNull(graphene.Int)
    total_disc_count = graphene.NonNull(graphene.Int)
    album_art_url = graphene.String()

    @staticmethod
    def resolve_artist(parent, info):
        artists = Counter(
            [
                song["albumArtist"]
                for song in db.get_db().get_songs()
                if "albumArtist" in song
                and song["albumArtist"] != ""
                and "album" in song
                and parent["name"] == song["album"]
            ]
        )
        if len(artists) > 0:
            (artist, _), *_ = artists.most_common(1)
            return {"name": artist}

    @staticmethod
    def resolve_tracks(parent, info):
        return [
            song
            for song in db.get_db().get_songs()
            if "album" in song and parent["name"] == song["album"]
        ]

    @staticmethod
    def resolve_total_track_count(parent, info):
        counts = Counter(
            [
                song["totalTrackCount"]
                for song in db.get_db().get_songs()
                if "totalTrackCount" in song
                and "album" in song
                and parent["name"] == song["album"]
            ]
        )
        if len(counts) > 0:
            (count, _), *_ = counts.most_common(1)
            return count
        else:
            return 1

    @staticmethod
    def resolve_total_disc_count(parent, info):
        counts = Counter(
            [
                song["totalDiscCount"]
                for song in db.get_db().get_songs()
                if "totalDiscCount" in song
                and "album" in song
                and parent["name"] == song["album"]
            ]
        )
        if len(counts) > 0:
            (count, _), *_ = counts.most_common(1)
            return count
        else:
            return 0

    @staticmethod
    def resolve_album_art_url(parent, info):
        urls = Counter(
            [
                ref["url"]
                for song in db.get_db().get_songs()
                if "albumArtRef" in song
                and "album" in song
                and parent["name"] == song["album"]
                for ref in song["albumArtRef"]
                if "url" in ref and ref["url"] != ""
            ]
        )
        if len(urls) > 0:
            (url, _), *_ = urls.most_common(1)
            return url


class Artist(graphene.ObjectType):
    name = graphene.NonNull(graphene.String)
    albums = graphene.NonNull(graphene.List(lambda: graphene.NonNull(Album)))

    @staticmethod
    def resolve_albums(parent, info):
        albums = {
            song["album"]
            for song in db.get_db().get_songs()
            if "album" in song
            and song["album"] != ""
            and "artist" in song
            and parent["name"] == song["albumArtist"]
        }
        return [{"name": album} for album in albums]


class RootQuery(graphene.ObjectType):
    songs = graphene.NonNull(
        graphene.List(lambda: graphene.NonNull(Song)),
        title=graphene.String(),
        search=graphene.String(),
    )
    artists = graphene.NonNull(
        graphene.List(lambda: graphene.NonNull(Artist)),
        name=graphene.String(),
        search=graphene.String(),
    )
    albums = graphene.NonNull(
        graphene.List(lambda: graphene.NonNull(Album)),
        name=graphene.String(),
        search=graphene.String(),
    )

    @staticmethod
    def resolve_songs(parent, info, title="", search=""):
        return [
            song
            for song in db.get_db().get_songs()
            if title.lower() in song["title"].lower()
            and (
                search.lower() in song["title"].lower()
                or ("artist" in song and search.lower() in song["artist"].lower())
                or (
                    "albumArtist" in song
                    and search.lower() in song["albumArtist"].lower()
                )
                or ("album" in song and search.lower() in song["album"].lower())
            )
        ]

    @staticmethod
    def resolve_artists(parent, info, name="", search=""):
        return [
            {"name": artist}
            for artist in {
                song["albumArtist"]
                for song in db.get_db().get_songs()
                if "albumArtist" in song
                and song["albumArtist"] != ""
                and name.lower() in song["albumArtist"].lower()
                and (
                    search.lower() in song["title"].lower()
                    or ("artist" in song and search.lower() in song["artist"].lower())
                    or search.lower() in song["albumArtist"].lower()
                    or ("album" in song and search.lower() in song["album"].lower())
                )
            }
        ]

    @staticmethod
    def resolve_albums(parent, info, name="", search=""):
        return [
            {"name": album}
            for album in {
                song["album"]
                for song in db.get_db().get_songs()
                if "album" in song
                and song["album"] != ""
                and name.lower() in song["album"].lower()
                and (
                    search.lower() in song["title"].lower()
                    or ("artist" in song and search.lower() in song["artist"].lower())
                    or (
                        "albumArtist" in song
                        and search.lower() in song["albumArtist"].lower()
                    )
                    or search.lower() in song["album"].lower()
                )
            }
        ]


schema = graphene.Schema(query=RootQuery)
