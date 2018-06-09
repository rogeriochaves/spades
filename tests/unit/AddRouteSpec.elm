module AddRouteSpec exposing (..)

import AddRoute
import Elm.Parser as Parser
import Elm.Processing as Processing
import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Ranged exposing (..)
import Elm.Writer as Writer
import Expect exposing (Expectation)
import Regex exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "AddRoute"
        [ describe "addPageType"
            [ test "adds a page to the Page type" <|
                \_ ->
                    (fixtureFileHeader ++ fixturePageTypeBefore)
                        |> applyTransformer (AddRoute.addPageType "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixturePageTypeAfter)
            , test "ignores other types" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureSomeOtherType)
                        |> applyTransformer (AddRoute.addPageType "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureSomeOtherType)
            ]
        , describe "addRouteToPath"
            [ test "adds a route on the toPath function" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureToPathBefore)
                        |> applyTransformer (AddRoute.addRouteToPath "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureToPathAfter)
            , test "ignores other functions" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureSomeOtherCase)
                        |> applyTransformer (AddRoute.addRouteToPath "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureSomeOtherCase)
            ]
        , describe "addRouteParser"
            [ test "adds a parser to the routes function" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureRoutesBefore)
                        |> applyTransformer (AddRoute.addRouteParser "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureRoutesAfter)
            , test "ignores other functions" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureSomeOtherRoutesFunction)
                        |> applyTransformer (AddRoute.addRouteParser "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureSomeOtherRoutesFunction)
            ]
        , test "transforms the whole file" <|
            \() ->
                let
                    fullFileBefore =
                        fixtureFileHeader ++ fixturePageTypeBefore ++ fixtureToPathBefore ++ fixtureRoutesBefore

                    fullFileAfter =
                        fixtureFileHeader ++ fixturePageTypeAfter ++ fixtureToPathAfter ++ fixtureRoutesAfter
                in
                fullFileBefore
                    |> AddRoute.transform "Example"
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


applyTransformer : (Ranged Declaration -> Ranged Declaration) -> String -> Result (List String) String
applyTransformer transformer string =
    stringToFile string
        |> Result.map (AddRoute.updateDeclarations transformer >> fileToString >> clearWhitespace)


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
        >> replace All (regex "\\[ ") (\_ -> "[")
        >> replace All (regex " \\]") (\_ -> "]")
        >> replace All (regex "\\| ") (\_ -> "|")
        >> replace All (regex " $") (\_ -> "")


fixturePageTypeBefore : String
fixturePageTypeBefore =
    """
type Page
    = Home
    | NotFound
    | CatsPage
    | CounterPage
"""


fixturePageTypeAfter : String
fixturePageTypeAfter =
    """
type Page
    = Home
    | NotFound
    | CatsPage
    | CounterPage
    | ExamplePage
"""


fixtureSomeOtherType : String
fixtureSomeOtherType =
    """
type MyCrazyType
    = Foo
    | Bar
"""


fixtureToPathBefore : String
fixtureToPathBefore =
    """
toPath : Page -> String
toPath page =
    case page of
        Home ->
            "/"
"""


fixtureToPathAfter : String
fixtureToPathAfter =
    """
toPath : Page -> String
toPath page =
    case page of
        Home ->
            "/"

        ExamplePage ->
            "/example"
"""


fixtureSomeOtherCase : String
fixtureSomeOtherCase =
    """
someOtherCase : Page -> String
someOtherCase page =
    case page of
        Home ->
            "/"
"""


fixtureRoutesBefore : String
fixtureRoutesBefore =
    """
routes : Parser (Page -> a) a
routes =
    oneOf
        [ map Home top
        , map NotFound (s "404")
        , map CatsPage (s "cats")
        , map CounterPage (s "counter")
        ]
"""


fixtureRoutesAfter : String
fixtureRoutesAfter =
    """
routes : Parser (Page -> a) a
routes =
    oneOf
        [ map Home top
        , map NotFound (s "404")
        , map CatsPage (s "cats")
        , map CounterPage (s "counter")
        , map ExamplePage (s "example")
        ]
"""


fixtureSomeOtherRoutesFunction : String
fixtureSomeOtherRoutesFunction =
    """
otherRoutes : Parser (Page -> a) a
otherRoutes =
    oneOf
        [ map Home top
        ]
"""
