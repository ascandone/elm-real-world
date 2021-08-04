module Misc exposing (..)

import Browser.Dom
import Expect exposing (Expectation)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode exposing (Value)
import Task


defaultImage : Maybe String -> String
defaultImage =
    Maybe.withDefault "https://static.productionready.io/images/smiley-cyrus.jpg"


optionalMaybe : String -> Decoder a -> Decoder (Maybe a -> b) -> Decoder b
optionalMaybe field decoder =
    optional field (Json.Decode.map Just decoder) Nothing


jumpToTop : msg -> Cmd msg
jumpToTop msg =
    Browser.Dom.setViewport 0.0 0.0
        |> Task.perform (\() -> msg)


encodeMaybe : (a -> Value) -> Maybe a -> Value
encodeMaybe enc m =
    case m of
        Nothing ->
            Json.Encode.null

        Just x ->
            enc x


expectIso : Decoder x -> (x -> Value) -> x -> Expectation
expectIso decoder encode x =
    Json.Decode.decodeValue decoder (encode x)
        |> Expect.equal (Ok x)
