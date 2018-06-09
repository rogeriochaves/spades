module Example exposing (..)

import AddRoute
import Expect exposing (Expectation)
import Regex exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "AddRoute"
        [ test "adds a page to the Page type" <|
            \_ ->
                let
                    before =
                        routerFileHeader
                            ++ """
type Page
    = Home
    | NotFound
    | CatsPage
    | CounterPage
"""

                    after =
                        routerFileHeader
                            ++ """
type Page
    = Home
    | NotFound
    | CatsPage
    | CounterPage
    | NewRoute
"""
                in
                AddRoute.transform before
                    |> Result.map clearWhitespace
                    |> Expect.equal (Ok <| clearWhitespace after)
        ]


routerFileHeader : String
routerFileHeader =
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
