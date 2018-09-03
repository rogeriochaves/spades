port module Main exposing (Flags, init, main, onError, onSuccess)

import Browser
import Html exposing (..)
import Transformers.AddComponentTypes as AddComponentTypes
import Transformers.AddComponentUpdate as AddComponentUpdate
import Transformers.AddComponentView as AddComponentView
import Transformers.AddRoute as AddRoute


type alias Flags =
    { transformer : String, args : { name : String }, code : String }


init : Flags -> ( (), Cmd msg )
init { transformer, args, code } =
    let
        transformed =
            case transformer of
                "ADD_ROUTE" ->
                    AddRoute.transform args.name code

                "ADD_COMPONENT_VIEW" ->
                    AddComponentView.transform args.name code

                "ADD_COMPONENT_TYPES" ->
                    AddComponentTypes.transform args.name code

                "ADD_COMPONENT_UPDATE" ->
                    AddComponentUpdate.transform args.name code

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
    Browser.element
        { init = init
        , update = always <| always ( (), Cmd.none )
        , view = always <| text ""
        , subscriptions = always Sub.none
        }


port onSuccess : String -> Cmd msg


port onError : String -> Cmd msg
