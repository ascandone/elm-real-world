module Api.Articles.Slug_.Favorite exposing (delete, post)

import Api.Internal
import Data.Article as Article exposing (Article)


post : String -> Api.Internal.Request Article
post slug =
    Api.Internal.post Article.decoderSingle [ "articles", slug, "favorite" ]


delete : String -> Api.Internal.Request Article
delete slug =
    Api.Internal.delete Article.decoderSingle [ "articles", slug, "favorite" ]
