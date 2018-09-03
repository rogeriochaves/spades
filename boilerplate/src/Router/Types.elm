module Router.Types exposing (Model, Msg(..))

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Router.Routes exposing (..)
import Url exposing (Url)


type alias Model =
    { page : Page
    , key : Key
    }


type Msg
    = OnUrlChange Url
    | OnUrlRequest UrlRequest
    | Go Page
