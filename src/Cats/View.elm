module Cats.View exposing (..)

import Cats.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text model.topic ]
        , button [ onClick MorePlease ] [ text "More Please!" ]
        , br [] []
        , case model.gifUrl of
            NotAsked ->
                text ""

            Loading ->
                text "Loading..."

            Success gifUrl ->
                img [ src gifUrl ] []

            Failure _ ->
                text "Error loading gif"
        ]
