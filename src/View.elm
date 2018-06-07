module View exposing (..)

import Cats.View
import Counter.View
import Element exposing (..)
import Element.Attributes exposing (..)
import Html exposing (..)
import Styles exposing (..)
import Types exposing (..)


view : Model -> Html Msg
view model =
    Element.layout stylesheet <|
        column NoStyle
            [ width (px 400) ]
            [ Element.map MsgForCats (Cats.View.view model.cats)
            , Element.map MsgForCounter (Counter.View.view model.counter)
            ]
