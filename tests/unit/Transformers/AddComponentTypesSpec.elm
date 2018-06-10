module Transformers.AddComponentTypesSpec exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import TestHelpers exposing (..)
import Transformers.AddComponentTypes as AddComponentTypes
import Transformers.Helpers exposing (..)


suite : Test
suite =
    describe "AddComponentTypes"
        [ describe "addMsgType"
            [ test "adds a page to the Page type" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureMsgsBefore)
                        |> applyTransformer (AddComponentTypes.addMsgType "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureMsgsAfter)
            , test "ignores other types" <|
                \_ ->
                    (fixtureFileHeader ++ fixtureSomeOtherType)
                        |> applyTransformer (AddComponentTypes.addMsgType "Example")
                        |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeader ++ fixtureSomeOtherType)
            ]
        ]


fixtureFileHeader : String
fixtureFileHeader =
    """
module Types exposing (..)
"""


fixtureMsgsBefore : String
fixtureMsgsBefore =
    """
type Msg
    = MsgForRouter Router.Types.Msg
    | MsgForCats Cats.Types.Msg
    | MsgForCounter Counter.Types.Msg
"""


fixtureMsgsAfter : String
fixtureMsgsAfter =
    """
type Msg
    = MsgForRouter Router.Types.Msg
    | MsgForCats Cats.Types.Msg
    | MsgForCounter Counter.Types.Msg
    | MsgForExample Example.Types.Msg
"""


fixtureSomeOtherType : String
fixtureSomeOtherType =
    """
type MyCrazyType
    = Foo
    | Bar
"""
