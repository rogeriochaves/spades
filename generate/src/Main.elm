port module Main exposing (..)

import Elm.Parser exposing (parse)
import Html exposing (..)


type alias Flags =
    { code : String }


init : Flags -> ( (), Cmd msg )
init { code } =
    ( (), output (addRoute code) )


addRoute : String -> String
addRoute code =
    case parse code of
        Ok file ->
            toString file

        Err errors ->
            "Error parsing file:\n"
                ++ String.join "\n" errors


main : Program Flags () msg
main =
    Html.programWithFlags
        { init = init
        , update = always <| always ( (), Cmd.none )
        , view = always <| text ""
        , subscriptions = always Sub.none
        }


port output : String -> Cmd msg
