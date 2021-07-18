module Api.Articles.Feed exposing (get, limit, offset)

import Api.Internal
import Data.Article as Article
import Data.User exposing (User)
import Url.Builder as Builder exposing (QueryParameter)


type Param
    = Param QueryParameter


limit : Int -> Param
limit =
    Param << Builder.int "limit"


offset : Int -> Param
offset =
    Param << Builder.int "offset"


toParams : List Param -> List QueryParameter
toParams =
    List.map (\(Param p) -> p)


get : User -> List Param -> Api.Internal.Request Article.Collection
get user params =
    Api.Internal.get Article.decoderCollection [ "articles", "feed" ]
        |> Api.Internal.withParams (toParams params)
        |> Api.Internal.withAuth user
