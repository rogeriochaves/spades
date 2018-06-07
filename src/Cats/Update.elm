module Cats.Update exposing (..)

import Cats.Data exposing (..)
import Cats.Types exposing (..)
import RemoteData exposing (..)
import Types


init : ( Model, Cmd Msg )
init =
    ( { topic = "cats"
      , gifUrl = NotAsked
      }
    , getRandomGif "cats"
    )


update : Types.Msg -> Model -> ( Model, Cmd Msg )
update msgFor model =
    case msgFor of
        Types.MsgForCats msg ->
            updateCats msg model


updateCats : Msg -> Model -> ( Model, Cmd Msg )
updateCats msg model =
    case msg of
        MorePlease ->
            ( { model | gifUrl = Loading }, getRandomGif model.topic )

        NewGif result ->
            ( { model | gifUrl = result }, Cmd.none )
