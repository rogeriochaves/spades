module View exposing (renderRoute, view)

import Browser
import Cats.View
import Counter.View
import Element exposing (..)
import Element.Events exposing (..)
import Element.Input exposing (button)
import Element.Region exposing (..)
import Router.Routes exposing (..)
import Router.Types exposing (Msg(..))
import Styles
import Types exposing (..)


view : Model -> Browser.Document Types.Msg
view model =
    { title = "projectname"
    , body =
        [ Element.layout [] <|
            el [ width (px 800), centerX ] (renderRoute model)
        ]
    }


renderRoute : Model -> Element Types.Msg
renderRoute model =
    case model.router.page of
        Home ->
            column
                [ spacing 5 ]
                [ el ([ heading 1 ] ++ Styles.title) (text "Welcome")
                , row [ spacing 5 ]
                    [ button ([ padding 5 ] ++ Styles.button) { onPress = Just (MsgForRouter <| Go CatsPage), label = text "Go to Cats" }
                    , button ([ padding 5 ] ++ Styles.button) { onPress = Just (MsgForRouter <| Go CounterPage), label = text "Go to Counter" }
                    ]
                ]

        NotFound ->
            text "404 Not Found"

        CatsPage ->
            Element.map MsgForCats (Cats.View.view model.cats)

        CounterPage ->
            Element.map MsgForCounter (Counter.View.view model.counter)
