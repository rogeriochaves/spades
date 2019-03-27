module Cats.Data exposing (..)

import Cats.Types exposing (..)
import Http
import Json.Decode as Decode
import RemoteData exposing (..)


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    let
        url =
            "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic

        returnMsg =
            RemoteData.fromResult >> NewGif
    in
    Http.get
        { url = url
        , expect = Http.expectJson returnMsg decodeGifUrl
        }


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
    Decode.at [ "data", "image_url" ] Decode.string
