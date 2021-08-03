module Data.Article exposing
    ( Article
    , Collection
    , decoderCollection
    , decoderSingle
    , replaceArticle
    )

import Data.Profile as Profile exposing (Profile)
import Iso8601
import Json.Decode exposing (Decoder, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Time exposing (Posix)


type alias Article =
    { slug : String
    , title : String
    , description : String
    , body : String
    , tagList : List String
    , createdAt : Posix
    , updatedAt : Posix
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
        |> required "createdAt" Iso8601.decoder
        |> required "updatedAt" Iso8601.decoder
        |> required "favorited" bool
        |> required "favoritesCount" int
        |> required "author" Profile.decoder


decoderSingle : Decoder Article
decoderSingle =
    succeed identity
        |> required "article" decoder


type alias Collection =
    { articles : List Article
    , articlesCount : Int
    }


decoderCollection : Decoder Collection
decoderCollection =
    succeed Collection
        |> required "articles" (list decoder)
        |> required "articlesCount" int


replaceArticle : Article -> Collection -> Collection
replaceArticle newArticle collection =
    { collection
        | articles =
            collection.articles
                |> List.map
                    (\article ->
                        if article.slug /= newArticle.slug then
                            article

                        else
                            newArticle
                    )
    }
