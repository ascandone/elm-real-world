module Page.NotFound exposing (..)

import Html exposing (..)


view : ( Maybe String, Html msg )
view =
    ( Just "Not found", text "Not found" )
