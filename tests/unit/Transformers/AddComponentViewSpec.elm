module Transformers.AddComponentViewSpec exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import TestHelpers exposing (..)
import Transformers.AddComponentView as AddComponentView
import Transformers.Helpers exposing (..)


suite : Test
suite =
    describe "AddComponentView"
        [ describe "addRenderRoute"
            [ test "adds a page to the renderRoute function" <|
                \_ ->
                    (fixtureFileHeaderBefore ++ fixtureRenderRouteBefore)
                        |> applyTransformer (AddComponentView.addRenderRoute "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeaderBefore ++ fixtureRenderRouteAfter)
            , test "ignores other types" <|
                \_ ->
                    (fixtureFileHeaderBefore ++ fixtureSomeOtherCase)
                        |> applyTransformer (AddComponentView.addRenderRoute "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeaderBefore ++ fixtureSomeOtherCase)
            ]
        , describe "addImportView"
            [ test "adds an import to the new view" <|
                \_ ->
                    fixtureFileHeaderBefore
                        |> stringToFile
                        |> Result.map (AddComponentView.addImportView "Example" >> fileToString >> clearWhitespace)
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeaderAfter)
            ]
        , test "transforms the whole file" <|
            \() ->
                let
                    fullFileBefore =
                        fixtureFileHeaderBefore ++ fixtureRenderRouteBefore

                    fullFileAfter =
                        fixtureFileHeaderAfter ++ fixtureRenderRouteAfter
                in
                fullFileBefore
                    |> AddComponentView.transform "Example"
                    |> Result.map clearWhitespace
                    |> Expect.equal (Ok <| clearWhitespace fullFileAfter)
        ]


fixtureFileHeaderBefore : String
fixtureFileHeaderBefore =
    """
module View exposing (..)

import Counter.View
"""


fixtureFileHeaderAfter : String
fixtureFileHeaderAfter =
    """
module View exposing (..)

import Counter.View
import Example.View
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
