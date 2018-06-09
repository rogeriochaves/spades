port module Main exposing (..)

import Html exposing (..)
import Transformers.AddRoute as AddRoute
import Transformers.AddView as AddView


type alias Flags =
    { transformer : String, args : { name : String }, code : String }


init : Flags -> ( (), Cmd msg )
init { transformer, args, code } =
    let
        transformed =
            case transformer of
                "ADD_ROUTE" ->
                    AddRoute.transform args.name code

                "ADD_VIEW" ->
                    AddView.transform args.name code

                _ ->
                    Err "Code transformer not found"
    in
    case transformed of
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
