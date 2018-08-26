module View exposing (renderRoute, view)

import Browser
import Cats.View
import Counter.View
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Router.Routes exposing (..)
import Router.Types exposing (Msg(..))
import Styles exposing (..)
import Types exposing (..)


view : Model -> Browser.Document Types.Msg
view model =
    { title = "projectname"
    , body =
        [ Element.layout stylesheet <|
            el NoStyle [ width (px 800) ] (renderRoute model)
        ]
    }


renderRoute : Model -> Element Styles variation Types.Msg
renderRoute model =
    case model.router.page of
        Home ->
            column NoStyle
                [ spacing 5 ]
                [ h1 Title [] (text "Welcome")
                , row NoStyle
                    [ spacing 5 ]
                    [ button NoStyle [ padding 5, onClick (MsgForRouter <| Go CatsPage) ] (text "Go to Cats")
                    , button NoStyle [ padding 5, onClick (MsgForRouter <| Go CounterPage) ] (text "Go to Counter")
                    ]
                ]

        NotFound ->
            text "404 Not Found"

        CatsPage ->
            Element.map MsgForCats (Cats.View.view model.cats)

        CounterPage ->
            Element.map MsgForCounter (Counter.View.view model.counter)
