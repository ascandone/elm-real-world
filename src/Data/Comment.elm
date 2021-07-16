module Data.Comment exposing (Comment, decoderMultiple, decoderSingle)

import Data.Profile as Profile exposing (Profile)
import Json.Decode exposing (Decoder, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)


type alias Comment =
    { id : Int
    , createdAt : String
    , updatedAt : String
    , body : String
    , author : Profile
    }


decoder : Decoder Comment
decoder =
    succeed Comment
        |> required "id" int
        |> required "createdAt" string
        |> required "updatedAt" string
        |> required "body" string
        |> required "author" Profile.decoder


decoderSingle : Decoder Comment
decoderSingle =
    field "comment" decoder


decoderMultiple : Decoder (List Comment)
decoderMultiple =
    field "comments" (list decoder)
