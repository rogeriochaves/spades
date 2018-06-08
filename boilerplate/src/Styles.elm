module Styles exposing (..)

import Style exposing (..)
import Style.Color as Color
import Style.Font as Font


type Styles
    = NoStyle
    | Title


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ style NoStyle []
        , style Title
            [ Color.text (rgb 0 0 0)
            , Font.size 40
            ]
        ]
