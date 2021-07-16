module Api.Articles exposing
    ( author
    , favorited
    , get
    , limit
    , offset
    , tag
    )

import Api.Internal
import Data.Article as Article exposing (Article)
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


get : List Param -> Api.Internal.Request (List Article)
get params =
    Api.Internal.get Article.decoderMultiple [ "articles" ]
        |> Api.Internal.withParams (toParams params)
