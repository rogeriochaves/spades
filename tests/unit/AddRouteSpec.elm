module AddRouteSpec exposing (..)

import AddRoute
import Elm.Parser as Parser
import Elm.Processing as Processing
import Elm.Syntax.File exposing (..)
import Elm.Writer as Writer
import Expect exposing (Expectation)
import Regex exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "AddRoute"
        [ test "adds a page to the Page type" <|
            \_ ->
                (fixtureFileHeader ++ fixturePageTypeBefore)
                    |> applyTransformer AddRoute.addPageType
                    |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixturePageTypeAfter)
        , describe "addRouteToPath"
            [ test "adds a route on the toPath function" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureToPathBefore)
                        |> applyTransformer AddRoute.addRouteToPath
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureToPathAfter)
            , test "ignore other functions" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureSomeOtherCase)
                        |> applyTransformer AddRoute.addRouteToPath
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureSomeOtherCase)
            ]
        , test "transforms the whole file" <|
            \() ->
                let
                    fullFileBefore =
                        fixtureFileHeader ++ fixturePageTypeBefore ++ fixtureToPathBefore

                    fullFileAfter =
                        fixtureFileHeader ++ fixturePageTypeAfter ++ fixtureToPathAfter
                in
                fullFileBefore
                    |> AddRoute.transform
                    |> Result.map clearWhitespace
                    |> Expect.equal (Ok <| clearWhitespace fullFileAfter)
        ]


stringToFile : String -> Result (List String) File
stringToFile string =
    Parser.parse string
        |> Result.map (Processing.process Processing.init)


fileToString : File -> String
fileToString file =
    Writer.writeFile file
        |> Writer.write


applyTransformer : (File -> File) -> String -> Result (List String) String
applyTransformer transformer string =
    stringToFile string
        |> Result.map (transformer >> fileToString >> clearWhitespace)


fixtureFileHeader : String
fixtureFileHeader =
    """
module Router.Routes exposing (..)

import Browser.Navigation
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, top)
"""


clearWhitespace : String -> String
clearWhitespace =
    replace All (regex "\\s+module") (\_ -> "module")
        >> replace All (regex "\\s+") (\_ -> " ")
        >> replace All (regex "= ") (\_ -> "=")
        >> replace All (regex "\\| ") (\_ -> "|")
        >> replace All (regex " $") (\_ -> "")


fixturePageTypeBefore =
    """
type Page
    = Home
    | NotFound
    | CatsPage
    | CounterPage
"""


fixturePageTypeAfter =
    """
type Page
    = Home
    | NotFound
    | CatsPage
    | CounterPage
    | NewRoute
"""


fixtureToPathBefore =
    """
toPath : Page -> String
toPath page =
    case page of
        Home ->
            "/"
"""


fixtureToPathAfter =
    """
toPath : Page -> String
toPath page =
    case page of
        Home ->
            "/"

        NewRoute ->
            "/new-route"
"""


fixtureSomeOtherCase =
    """
someOtherCase : Page -> String
someOtherCase page =
    case page of
        Home ->
            "/"
"""
