module Counter.View exposing (..)

import Counter.Types exposing (..)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import RemoteData exposing (..)
import Styles exposing (..)


view : Model -> Element Styles variation Msg
view model =
    row NoStyle
        [ verticalCenter, spacing 5 ]
        [ button NoStyle [ padding 5, onClick Decrement ] (text "-")
        , text (String.fromInt model)
        , button NoStyle [ padding 5, onClick Increment ] (text "+")
        ]
