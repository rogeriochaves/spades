module Counter.Update exposing (init, update)

import Counter.Types exposing (..)
import RemoteData exposing (..)
import Return exposing (Return, return)
import Types


init : Return Msg Model
init =
    return 0 Cmd.none


update : Types.Msg -> Model -> Return Msg Model
update msgFor model =
    case msgFor of
        Types.MsgForCounter msg ->
            updateCounter msg model

        _ ->
            return model Cmd.none


updateCounter : Msg -> Model -> Return Msg Model
updateCounter msg model =
    case msg of
        Increment ->
            return (model + 1) Cmd.none

        Decrement ->
            return (model - 1) Cmd.none
