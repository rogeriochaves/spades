module <%= name %>.Update exposing (..)

import <%= name %>.Types exposing (..)
import Helpers.Return exposing (Return, return)
import Types


init : Return Msg Model
init =
    return
        { sample : String
        }
        Cmd.none


update : Types.Msg -> Model -> Return Msg Model
update msgFor model =
    case msgFor of
        Types.MsgFor<%= name %> msg ->
            update<%= name %> msg model

        _ ->
            return model Cmd.none


update<%= name %> : Msg -> Model -> Return Msg Model
update<%= name %> msg model =
    case msg of
        NoOp ->
            return model Cmd.none
