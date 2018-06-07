module Types exposing (..)

import Cats.Types
import Counter.Types


type alias Model =
    { cats : Cats.Types.Model
    , counter : Counter.Types.Model
    }


type Msg
    = MsgForCats Cats.Types.Msg
    | MsgForCounter Counter.Types.Msg
