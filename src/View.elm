module View exposing (..)

import Cats.View
import Html exposing (..)
import Types exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ Html.map MsgForCats (Cats.View.view model.cats)
        ]
