import json

from gmusicapi import Mobileclient
from graphene import ID, Field, Int, List, NonNull, ObjectType, Schema, String

api = Mobileclient()
# api.perform_oauth(storage_filepath='credentials.txt', open_browser=True)
api.oauth_login(
    'd3e01d7caa84e5da7f7f400f108e2df28852b67251f0199049c7d65de6252b70')

library = api.get_all_songs()
artist_ids = set()
artists = {}
albums = {}


def get_artist(artist_id):
    try:
        if artist_id in artists.keys():
            return artists[artist_id]
        else:
            artist = {'id': artist_id,
                      **api.get_artist_info(artist_id, include_albums=False)}
            artists[artist_id] = artist
            return artist
    except Exception as ex:
        return None


def get_album(album_id):
    try:
        if album_id in albums.keys():
            return albums[album_id]
        else:
            album = {'id': album_id,
                     **api.get_album_info(album_id, include_tracks=False)}
            albums[album_id] = album
            return album
    except Exception as ex:
        return None


class Song(ObjectType):
    id = NonNull(ID)
    title = NonNull(String)
    artists = NonNull(List(lambda: NonNull(Artist)))
    album = Field(lambda: Album)

    @staticmethod
    def resolve_artists(parent, info):
        if 'artistId' in parent:
            return [artist for artist in [get_artist(artist_id) for artist_id in parent['artistId']]
                    if artist is not None]
        else:
            return []

    @staticmethod
    def resolve_album(parent, info):
        if 'albumId' in parent:
            return get_album(parent['albumId'])
        else:
            return None


class Album(ObjectType):
    id = NonNull(ID)
    name = NonNull(String)
    artists = NonNull(List(lambda: NonNull(Artist)))
    tracks = NonNull(List(lambda: NonNull(Song)))

    @staticmethod
    def resolve_artists(parent, info):
        if 'artistId' in parent:
            return [artist for artist in [get_artist(artist_id) for artist_id in parent['artistId']]
                    if artist is not None]
        else:
            return []

    @staticmethod
    def resolve_tracks(parent, info):
        return [song for song in library
                if 'albumId' in song and song['albumId'] is parent['id']]


class Artist(ObjectType):
    id = NonNull(ID)
    name = NonNull(String)
    albums = NonNull(List(lambda: NonNull(Album)))

    @staticmethod
    def resolve_albums(parent, info):
        album_ids = {song['albumId'] for song in library
                     if 'albumId' in song
                     and 'artistId' in song
                     and parent['id'] in song['artistId']}

        return [album for album in [get_album(album_id) for album_id in album_ids]
                if album is not None]


class RootQuery(ObjectType):
    songs = NonNull(List(lambda: NonNull(Song)), first=Int())

    @staticmethod
    def resolve_songs(parent, info, first):
        if (first is not None):
            return library[:first]
        else:
            return library


schema = Schema(query=RootQuery)

result = schema.execute(
    '''
  {
    songs(first: 100) {
      id
      title
      artists {
        id
        name
        albums {
          id
          name
        }
      }
      album {
        id
        name
        artists {
          id
          name
        }
        tracks {
          id
          title
        }
      }
    }
  }
  '''


)

# print(result)
items = dict(result.data.items())
print(json.dumps(items, indent=4))
