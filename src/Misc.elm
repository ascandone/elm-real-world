module Misc exposing (..)

import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional)


defaultImage : Maybe String -> String
defaultImage =
    Maybe.withDefault "https://static.productionready.io/images/smiley-cyrus.jpg"



--optionalMaybe : String -> Decoder a -> Decoder (a -> b) -> Decoder (Maybe b)


optionalMaybe : String -> Decoder a -> Decoder (Maybe a -> b) -> Decoder b
optionalMaybe field decoder =
    optional field (Json.Decode.map Just decoder) Nothing
