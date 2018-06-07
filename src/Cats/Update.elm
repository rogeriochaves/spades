module Cats.Update exposing (..)

import Cats.Data exposing (..)
import Cats.Types exposing (..)
import Helpers.Return exposing (Return, return)
import RemoteData exposing (..)
import Types


init : Return Msg Model
init =
    return
        { topic = "cats"
        , gifUrl = NotAsked
        }
        (getRandomGif "cats")


update : Types.Msg -> Model -> Return Msg Model
update msgFor model =
    case msgFor of
        Types.MsgForCats msg ->
            updateCats msg model


updateCats : Msg -> Model -> Return Msg Model
updateCats msg model =
    case msg of
        MorePlease ->
            return { model | gifUrl = Loading } (getRandomGif model.topic)

        NewGif result ->
            return { model | gifUrl = result } Cmd.none
