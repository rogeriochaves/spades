module Router.Types exposing (..)

import Router.Routes exposing (..)
import Url exposing (Url)


type alias Model =
    Page


type Msg
    = OnNavigation Url
    | Go Page
