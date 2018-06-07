port module Main exposing (..)

import Ast
import Ast.Expression exposing (..)
import Ast.Statement exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD


type alias Flags =
    { code : String }


init : Flags -> ( (), Cmd msg )
init { code } =
    ( (), output (addRoute code) )


addRoute code =
    case Ast.parse code of
        Ok ( _, _, statements ) ->
            toString statements

        Err ( _, _, err ) ->
            "Error parsing file:\n"
                ++ String.join "\n" err


main : Program Flags () msg
main =
    Html.programWithFlags
        { init = init
        , update = always <| always ( (), Cmd.none )
        , view = always <| text ""
        , subscriptions = always Sub.none
        }


port output : String -> Cmd msg
