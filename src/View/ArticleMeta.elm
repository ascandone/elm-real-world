module View.ArticleMeta exposing (view)

import Data.Article exposing (Article)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Misc


view : Article -> Html msg
view ({ author } as article) =
    div [ class "article-meta" ]
        [ a [ A.href "" ]
            [ img [ A.src (Misc.defaultImage author.image) ] [] ]
        , div [ class "info" ]
            [ a [ class "author", A.href "" ] [ text author.username ]
            , span [ class "date" ] [ text article.createdAt ] --TODO
            ]
        , button
            [ class "btn btn-sm"
            , class <|
                if author.following then
                    "btn-secondary"

                else
                    "btn-outline-secondary"
            ]
            [ i [ class "ion-plus-round" ] []
            , text "Follow "
            , text author.username
            ]
        , button
            [ class "btn btn-sm"
            , class <|
                if author.following then
                    "btn-primary"

                else
                    "btn-outline-primary"
            ]
            [ i [ class "ion-heart" ] []
            , text "Favorite Post"
            , span [ class "counter" ] [ text ("(" ++ String.fromInt article.favoritesCount ++ ")") ]
            ]
        ]
