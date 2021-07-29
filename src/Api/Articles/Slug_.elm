module Api.Articles.Slug_ exposing (PutBody, delete, get, put)

import Api.Internal
import Data.Article as Article exposing (Article)
import Data.User exposing (User)
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
        [ ( "title", encodeMaybe Enc.string body.title )
        , ( "description", encodeMaybe Enc.string body.description )
        , ( "body", encodeMaybe Enc.string body.body )
        ]


put : String -> PutBody -> Api.Internal.Request Article
put slug body =
    Api.Internal.get Article.decoderSingle [ "articles", slug ]
        |> Api.Internal.withBody (encodeBody body)


delete : User -> String -> Api.Internal.Request Article
delete user slug =
    Api.Internal.get Article.decoderSingle [ "articles", slug ]
        |> Api.Internal.withAuth user
