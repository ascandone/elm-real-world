module Data.Comment exposing (Comment, decoderMultiple, decoderSingle)

import Data.Profile as Profile exposing (Profile)
import Iso8601
import Json.Decode exposing (Decoder, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Time exposing (Posix)


type alias Comment =
    { id : Int
    , createdAt : Posix
    , updatedAt : Posix
    , body : String
    , author : Profile
    }


decoder : Decoder Comment
decoder =
    succeed Comment
        |> required "id" int
        |> required "createdAt" Iso8601.decoder
        |> required "updatedAt" Iso8601.decoder
        |> required "body" string
        |> required "author" Profile.decoder


decoderSingle : Decoder Comment
decoderSingle =
    field "comment" decoder


decoderMultiple : Decoder (List Comment)
decoderMultiple =
    field "comments" (list decoder)
