module Api.Articles exposing
    ( author
    , favorited
    , get
    , limit
    , offset
    , post
    , tag
    )

import Api.Internal
import Data.Article as Article exposing (Article)
import Data.User exposing (User)
import Json.Encode as Enc exposing (Value)
import Misc exposing (encodeMaybe)
import Url.Builder as Builder exposing (QueryParameter)


type Param
    = Param QueryParameter


tag : String -> Param
tag =
    Param << Builder.string "tag"


author : String -> Param
author =
    Param << Builder.string "author"


favorited : String -> Param
favorited =
    Param << Builder.string "author"


limit : Int -> Param
limit =
    Param << Builder.int "limit"


offset : Int -> Param
offset =
    Param << Builder.int "offset"


toParams : List Param -> List QueryParameter
toParams =
    List.map (\(Param p) -> p)


get : List Param -> Api.Internal.Request Article.Collection
get params =
    Api.Internal.get Article.decoderCollection [ "articles" ]
        |> Api.Internal.withParams (toParams params)


type alias PostBody =
    { title : String
    , description : String
    , body : String
    , tagList : Maybe (List String)
    }


encodeBody : PostBody -> Value
encodeBody body =
    Enc.object
        [ ( "title", Enc.string body.title )
        , ( "description", Enc.string body.description )
        , ( "body", Enc.string body.body )
        , ( "tagList", encodeMaybe (Enc.list Enc.string) body.tagList )
        ]


post : User -> PostBody -> Api.Internal.Request Article
post user body =
    Api.Internal.post Article.decoderSingle [ "articles" ]
        |> Api.Internal.withAuth user
        |> Api.Internal.withBody (encodeBody body)
