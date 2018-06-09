module AddViewSpec exposing (..)

import AddView
import Expect exposing (Expectation)
import Test exposing (..)
import TestHelpers exposing (..)


suite : Test
suite =
    describe "AddView"
        [ describe "addRenderRoute"
            [ only <|
                test "adds a page to the renderRoute function" <|
                    \_ ->
                        (fixtureFileHeader ++ fixtureRenderRouteBefore)
                            |> applyTransformer (AddView.addRenderRoute "Example")
                            |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureRenderRouteAfter)
            , test "ignores other types" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureSomeOtherCase)
                        |> applyTransformer (AddView.addRenderRoute "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureSomeOtherCase)
            ]
        , test "transforms the whole file" <|
            \() ->
                let
                    fullFileBefore =
                        fixtureFileHeader ++ fixtureRenderRouteBefore

                    fullFileAfter =
                        fixtureFileHeader ++ fixtureRenderRouteAfter
                in
                fullFileBefore
                    |> AddView.transform "Example"
                    |> Result.map clearWhitespace
                    |> Expect.equal (Ok <| clearWhitespace fullFileAfter)
        ]


fixtureFileHeader : String
fixtureFileHeader =
    """
module View exposing (..)

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
"""


fixtureRenderRouteBefore : String
fixtureRenderRouteBefore =
    """
renderRoute model =
    case model.router of
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
"""


fixtureRenderRouteAfter : String
fixtureRenderRouteAfter =
    """
renderRoute model =
    case model.router of
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

        ExamplePage ->
            Element.map MsgForExample (Example.View.view model.example)
"""


fixtureSomeOtherCase : String
fixtureSomeOtherCase =
    """
someOtherCase model =
    case model.router of
        Home ->
            "/"
"""
