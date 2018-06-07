module View exposing (..)

import Cats.View
import Element exposing (..)
import Html exposing (..)
import Styles exposing (..)
import Types exposing (..)


view : Model -> Html Msg
view model =
    Element.layout stylesheet <|
        row NoStyle
            []
            [ Element.map MsgForCats (Cats.View.view model.cats)
            ]
