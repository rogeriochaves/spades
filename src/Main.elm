module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Router.Types
import Types exposing (..)
import Update exposing (init, update)
import View exposing (view)


main : Program () Model Msg
main =
    Browser.fullscreen
        { init = init
        , update = update
        , view = view
        , onNavigation = Just (MsgForRouter << Router.Types.OnNavigation)
        , subscriptions = always Sub.none
        }
