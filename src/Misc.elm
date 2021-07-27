module Misc exposing (..)

import Browser.Dom
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional)
import Task


defaultImage : Maybe String -> String
defaultImage =
    Maybe.withDefault "https://static.productionready.io/images/smiley-cyrus.jpg"



--optionalMaybe : String -> Decoder a -> Decoder (a -> b) -> Decoder (Maybe b)


optionalMaybe : String -> Decoder a -> Decoder (Maybe a -> b) -> Decoder b
optionalMaybe field decoder =
    optional field (Json.Decode.map Just decoder) Nothing


jumpToTop : msg -> Cmd msg
jumpToTop msg =
    Browser.Dom.setViewport 0.0 0.0
        |> Task.perform (\() -> msg)
