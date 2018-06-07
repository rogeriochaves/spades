module Update exposing (..)

import Cats.Update
import Types exposing (..)


init : () -> ( Model, Cmd Msg )
init _ =
    let
        cats =
            Cats.Update.init
    in
    ( { cats = Tuple.first cats
      }
    , Cmd.batch
        [ Tuple.second cats |> Cmd.map MsgForCats
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        cats =
            Cats.Update.update msg model.cats
    in
    ( { model
        | cats = Tuple.first cats
      }
    , Cmd.batch
        [ Tuple.second cats |> Cmd.map MsgForCats
        ]
    )
