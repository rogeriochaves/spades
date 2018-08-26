module Router.Update exposing (init, update)

import Browser exposing (UrlRequest(..))
import Browser.Navigation exposing (Key, load, pushUrl)
import RemoteData exposing (..)
import Return exposing (Return, return)
import Router.Routes exposing (..)
import Router.Types exposing (..)
import Types
import Url exposing (Url)
import Url.Parser exposing (parse)


init : Url -> Key -> Return Msg Model
init url key =
    return
        { page = Maybe.withDefault NotFound <| parse routes url
        , key = key
        }
        Cmd.none


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
        OnUrlChange url ->
            return { model | page = Maybe.withDefault NotFound <| parse routes url } Cmd.none

        OnUrlRequest urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, pushUrl model.key <| Url.toString url )

                External url ->
                    ( model, load url )

        Go page ->
            return model (pushUrl model.key <| toPath page)
