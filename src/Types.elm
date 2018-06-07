module Types exposing (..)

import Cats.Types


type alias Model =
    { cats : Cats.Types.Model
    }


type Msg
    = MsgForCats Cats.Types.Msg
