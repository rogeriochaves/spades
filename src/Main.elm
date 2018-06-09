port module Main exposing (..)

import AddRoute
import Html exposing (..)


type alias Flags =
    { name : String, code : String }


init : Flags -> ( (), Cmd msg )
init { name, code } =
    case AddRoute.transform name code of
        Ok content ->
            ( (), onSuccess content )

        Err err ->
            ( (), onError err )


main : Program Flags () msg
main =
    Html.programWithFlags
        { init = init
        , update = always <| always ( (), Cmd.none )
        , view = always <| text ""
        , subscriptions = always Sub.none
        }


port onSuccess : String -> Cmd msg


port onError : String -> Cmd msg
