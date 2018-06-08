module Cats.View exposing (..)

import Cats.Types exposing (..)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import RemoteData exposing (..)
import Styles exposing (..)


view : Model -> Element Styles variation Msg
view model =
    column NoStyle
        []
        [ h2 Title [] (text model.topic)
        , button NoStyle [ onClick MorePlease ] (text "More Please!")
        , case model.gifUrl of
            NotAsked ->
                text ""

            Loading ->
                text "Loading..."

            Success gifUrl ->
                image NoStyle [] { src = gifUrl, caption = "a random " ++ model.topic ++ " gif" }

            Failure _ ->
                text "Error loading gif"
        ]
