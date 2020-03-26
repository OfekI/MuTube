from pytest import mark

library = [
    {
        "id": 1,
        "title": "Song 1",
        "artist": "Artist 1",
        "albumArtist": "Artist 1",
        "year": 2020,
        "album": "Album 1",
        "totalTrackCount": 3,
        "albumArtRef": [{"url": "fakeurl.com/album1.jpg"}],
    },
    {
        "id": 2,
        "title": "Song 2",
        "artist": "Artist 2",
        "albumArtist": "Artist 2",
        "year": 2019,
        "album": "Album 2",
    },
    {
        "id": 3,
        "title": "Song 3",
        "artist": "Artist 1, Artist 2",
        "albumArtist": "Artist 1",
        "year": 2020,
        "album": "Album 1",
        "trackNumber": 3,
        "totalTrackCount": 3,
    },
]


@mark.parametrize(
    "query,expected",
    [
        (
            """{
                songs {
                    id
                    title
                    year
                    trackNumber
                    discNumber
                }
            }""",
            {
                "songs": [
                    {
                        "id": "1",
                        "title": "Song 1",
                        "year": 2020,
                        "trackNumber": 1,
                        "discNumber": 0,
                    },
                    {
                        "id": "2",
                        "title": "Song 2",
                        "year": 2019,
                        "trackNumber": 1,
                        "discNumber": 0,
                    },
                    {
                        "id": "3",
                        "title": "Song 3",
                        "year": 2020,
                        "trackNumber": 3,
                        "discNumber": 0,
                    },
                ]
            },
        ),
        (
            """{
                songs {
                    title
                    artist {
                        name
                        albums {
                            name
                        }
                    }
                }
            }""",
            {
                "songs": [
                    {
                        "title": "Song 1",
                        "artist": {"name": "Artist 1", "albums": [{"name": "Album 1"}]},
                    },
                    {
                        "title": "Song 2",
                        "artist": {"name": "Artist 2", "albums": [{"name": "Album 2"}]},
                    },
                    {
                        "title": "Song 3",
                        "artist": {"name": "Artist 1, Artist 2", "albums": []},
                    },
                ]
            },
        ),
        (
            """{
                songs {
                    title
                    album {
                        name
                        artist {
                            name
                        }
                        tracks {
                            title
                        }
                        totalTrackCount
                        totalDiscCount
                        albumArtUrl
                    }
                }
            }""",
            {
                "songs": [
                    {
                        "title": "Song 1",
                        "album": {
                            "name": "Album 1",
                            "artist": {"name": "Artist 1"},
                            "tracks": [{"title": "Song 1"}, {"title": "Song 3"}],
                            "totalTrackCount": 3,
                            "totalDiscCount": 0,
                            "albumArtUrl": "fakeurl.com/album1.jpg",
                        },
                    },
                    {
                        "title": "Song 2",
                        "album": {
                            "name": "Album 2",
                            "artist": {"name": "Artist 2"},
                            "tracks": [{"title": "Song 2"}],
                            "totalTrackCount": 1,
                            "totalDiscCount": 0,
                            "albumArtUrl": None,
                        },
                    },
                    {
                        "title": "Song 3",
                        "album": {
                            "name": "Album 1",
                            "artist": {"name": "Artist 1"},
                            "tracks": [{"title": "Song 1"}, {"title": "Song 3"}],
                            "totalTrackCount": 3,
                            "totalDiscCount": 0,
                            "albumArtUrl": "fakeurl.com/album1.jpg",
                        },
                    },
                ]
            },
        ),
        (
            """{
                songs(title: "song 1") {
                    title
                }
            }""",
            {"songs": [{"title": "Song 1"}]},
        ),
        (
            """{
                songs(search: "artist 1") {
                    title
                }
            }""",
            {"songs": [{"title": "Song 1"}, {"title": "Song 3"}]},
        ),
    ],
)
def test_graphql_songs(query, expected, client, monkeypatch):
    monkeypatch.setattr(
        "gmusicapi.Mobileclient.get_all_songs", lambda *args: library,
    )
    response = client.post("/graphql", data={"query": query})
    assert response.get_json()["data"] == expected


@mark.parametrize(
    "query,expected",
    [
        (
            """{
                artists {
                    name
                    albums {
                        name
                        tracks {
                            title
                            artist {
                                name
                            }
                        }
                    }
                }
            }""",
            [
                {
                    "name": "Artist 1",
                    "albums": [
                        {
                            "name": "Album 1",
                            "tracks": [
                                {"title": "Song 1", "artist": {"name": "Artist 1"}},
                                {
                                    "title": "Song 3",
                                    "artist": {"name": "Artist 1, Artist 2"},
                                },
                            ],
                        }
                    ],
                },
                {
                    "name": "Artist 2",
                    "albums": [
                        {
                            "name": "Album 2",
                            "tracks": [
                                {"title": "Song 2", "artist": {"name": "Artist 2"}}
                            ],
                        }
                    ],
                },
            ],
        ),
        (
            """{
                artists(name: "artist 1") {
                    name
                }
            }""",
            [{"name": "Artist 1"}],
        ),
        (
            """{
                artists(search: "song 1") {
                    name
                }
            }""",
            [{"name": "Artist 1"}],
        ),
    ],
)
def test_graphql_artists(query, expected, client, monkeypatch):
    monkeypatch.setattr(
        "gmusicapi.Mobileclient.get_all_songs", lambda *args: library,
    )
    response = client.post("/graphql", data={"query": query})
    assert (
        sorted(response.get_json()["data"]["artists"], key=lambda d: d["name"])
        == expected
    )


@mark.parametrize(
    "query,expected",
    [
        (
            """{
                albums {
                    name
                    artist {
                        name
                    }
                    tracks {
                        title
                        artist {
                            name
                        }
                    }
                }
            }""",
            [
                {
                    "name": "Album 1",
                    "artist": {"name": "Artist 1"},
                    "tracks": [
                        {"title": "Song 1", "artist": {"name": "Artist 1"}},
                        {"title": "Song 3", "artist": {"name": "Artist 1, Artist 2"},},
                    ],
                },
                {
                    "name": "Album 2",
                    "artist": {"name": "Artist 2"},
                    "tracks": [{"title": "Song 2", "artist": {"name": "Artist 2"}}],
                },
            ],
        ),
        (
            """{
                albums(name: "album 1") {
                    name
                }
            }""",
            [{"name": "Album 1"}],
        ),
        (
            """{
                albums(search: "song 1") {
                    name
                }
            }""",
            [{"name": "Album 1"}],
        ),
    ],
)
def test_graphql_albums(query, expected, client, monkeypatch):
    monkeypatch.setattr(
        "gmusicapi.Mobileclient.get_all_songs", lambda *args: library,
    )
    response = client.post("/graphql", data={"query": query})
    assert (
        sorted(response.get_json()["data"]["albums"], key=lambda d: d["name"])
        == expected
    )
