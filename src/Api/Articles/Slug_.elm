module Api.Articles.Slug_ exposing (PutBody, delete, get, put)

import Api.Internal
import Data.Article as Article exposing (Article)
import Data.User exposing (User)
import Json.Decode
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


put : User -> String -> PutBody -> Api.Internal.Request Article
put user slug body =
    Api.Internal.put Article.decoderSingle [ "articles", slug ]
        |> Api.Internal.withBody (encodeBody body)
        |> Api.Internal.withAuth user


delete : User -> String -> Api.Internal.Request ()
delete user slug =
    Api.Internal.delete (Json.Decode.succeed ()) [ "articles", slug ]
        |> Api.Internal.withAuth user
