module Api.Articles.Slug_.Favorite exposing (delete, post)

import Api.Internal
import Data.Article as Article exposing (Article)
import Data.User exposing (User)


post : User -> String -> Api.Internal.Request Article
post user slug =
    Api.Internal.post Article.decoderSingle [ "articles", slug, "favorite" ]
        |> Api.Internal.withAuth user


delete : User -> String -> Api.Internal.Request Article
delete user slug =
    Api.Internal.delete Article.decoderSingle [ "articles", slug, "favorite" ]
        |> Api.Internal.withAuth user
