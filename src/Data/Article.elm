module Data.Article exposing (Article, decoderMultiple, decoderSingle)

import Data.Profile as Profile exposing (Profile)
import Json.Decode exposing (Decoder, bool, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)


type alias Article =
    { slug : String
    , title : String
    , description : String
    , body : String
    , tagList : List String
    , createdAt : String
    , updatedAt : String
    , favorited : Bool
    , favoritesCount : Int
    , author : Profile
    }


decoder : Decoder Article
decoder =
    succeed Article
        |> required "slug" string
        |> required "title" string
        |> required "description" string
        |> required "body" string
        |> required "tagList" (list string)
        |> required "createdAt" string
        |> required "updatedAt" string
        |> required "favorited" bool
        |> required "favoritesCount" int
        |> required "author" Profile.decoder


decoderSingle : Decoder Article
decoderSingle =
    field "article" decoder


decoderMultiple : Decoder (List Article)
decoderMultiple =
    field "articles" (list decoder)
