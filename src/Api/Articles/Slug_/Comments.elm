module Api.Articles.Slug_.Comments exposing (PostBody, delete, get, post)

import Api.Internal
import Data.Comment as Comment exposing (Comment)
import Data.User exposing (User)
import Json.Decode
import Json.Encode as Enc exposing (Value)


type alias PostBody =
    { body : String
    }


encodeBody : PostBody -> Value
encodeBody body =
    Enc.object
        [ ( "body", Enc.string body.body )
        ]


post : User -> PostBody -> String -> Api.Internal.Request Comment
post user body slug =
    Api.Internal.post Comment.decoderSingle [ "articles", slug, "comments" ]
        |> Api.Internal.withAuth user
        |> Api.Internal.withBody (encodeBody body)


get : String -> Api.Internal.Request (List Comment)
get slug =
    Api.Internal.get Comment.decoderMultiple [ "articles", slug, "comments" ]


delete : User -> String -> Int -> Api.Internal.Request ()
delete user slug id =
    Api.Internal.delete (Json.Decode.succeed ()) [ "articles", slug, "comments", String.fromInt id ]
        |> Api.Internal.withAuth user
