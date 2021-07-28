module Api.Articles.Slug_ exposing (PutBody, get, put)

import Api.Internal
import Data.Article as Article exposing (Article)
import Json.Encode as Enc exposing (Value)
import Misc exposing (encodeMaybe)


get : String -> Api.Internal.Request Article
get slug =
    Api.Internal.get Article.decoderSingle [ "articles", slug ]


type alias PutBody =
    { title : Maybe String
    , description : Maybe String
    , body : Maybe String
    }


encodeBody : PutBody -> Value
encodeBody body =
    Enc.object
        [ ( "title", encodeMaybe body.title Enc.string )
        , ( "description", encodeMaybe body.description Enc.string )
        , ( "body", encodeMaybe body.body Enc.string )
        ]


put : String -> PutBody -> Api.Internal.Request Article
put slug body =
    Api.Internal.get Article.decoderSingle [ "articles", slug ]
        |> Api.Internal.withBody (encodeBody body)
