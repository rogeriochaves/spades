module Cats.Types exposing (..)

import Http
import RemoteData exposing (..)


type alias Model =
    { topic : String
    , gifUrl : WebData String
    }


type Msg
    = MorePlease
    | NewGif (WebData String)
