module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Types exposing (..)
import Update exposing (init, update)
import View exposing (view)


main : Program () Model Msg
main =
    Browser.embed
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
