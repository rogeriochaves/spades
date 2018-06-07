module Router.Update exposing (..)

import Browser.Navigation exposing (pushUrl)
import Helpers.Return exposing (Return, return)
import RemoteData exposing (..)
import Router.Routes exposing (..)
import Router.Types exposing (..)
import Types
import Url.Parser exposing (parse)


init : Return Msg Model
init =
    return Home Cmd.none


update : Types.Msg -> Model -> Return Msg Model
update msgFor model =
    case msgFor of
        Types.MsgForRouter msg ->
            updateRouter msg model

        _ ->
            return model Cmd.none


updateRouter : Msg -> Model -> Return Msg Model
updateRouter msg model =
    case msg of
        OnNavigation url ->
            return (Maybe.withDefault NotFound <| parse routes url) Cmd.none

        Go page ->
            return model (pushUrl <| toPath page)
