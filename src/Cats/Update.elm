module Cats.Update exposing (..)

import Cats.Data exposing (..)
import Cats.Types exposing (..)
import Types


init : ( Model, Cmd Msg )
init =
    ( Model "cats" "waiting.gif"
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
            ( model, getRandomGif model.topic )

        NewGif (Ok newUrl) ->
            ( Model model.topic newUrl, Cmd.none )

        NewGif (Err _) ->
            ( model, Cmd.none )
