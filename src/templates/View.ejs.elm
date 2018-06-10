module <%= name %>.View exposing (..)

import <%= name %>.Types exposing (..)
import Element exposing (..)
import Styles exposing (..)


view : Model -> Element Styles variation Msg
view model =
    text "Edit me at src/<%= name %>/View.elm"
