module Cats.DataTest exposing (suite)

import Cats.Data exposing (..)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode
import Test exposing (..)


suite : Test
suite =
    test "decodes json from giphy api" <|
        \_ ->
            let
                fixture =
                    """
                    {
                        "data": {
                            "type": "gif",
                            "id": "3o7ate7xAJRAPujR3a",
                            "slug": "the-bachelor-ben-higgins-3o7ate7xAJRAPujR3a",
                            "url": "https://giphy.com/gifs/the-bachelor-ben-higgins-3o7ate7xAJRAPujR3a",
                            "bitly_gif_url": "https://gph.is/1PFy0sc",
                            "bitly_url": "https://gph.is/1PFy0sc",
                            "embed_url": "https://giphy.com/embed/3o7ate7xAJRAPujR3a",
                            "image_url": "foo.gif"
                        }
                    }
                    """
            in
            fixture
                |> Decode.decodeString decodeGifUrl
                |> Expect.equal (Ok "foo.gif")
