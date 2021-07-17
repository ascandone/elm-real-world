module View.ArticlePreview exposing (Msg(..), view)

import Api.Articles exposing (author)
import Data.Article exposing (Article)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events exposing (onClick)
import Misc exposing (defaultImage)
import Route


type Msg
    = ToggledFavorite


view : Article -> Html Msg
view ({ author } as article) =
    div [ class "article-preview" ]
        [ div [ class "article-meta" ]
            [ a [ A.href <| Route.toHref (Route.Profile author.username) ]
                [ img [ A.src (defaultImage author.image) ] [] ]
            , div [ class "info" ]
                [ a [ A.href <| Route.toHref (Route.Profile author.username), class "author" ] [ text author.username ]
                , span [ class "date" ] [ text article.createdAt ] --TODO date
                ]
            , button
                [ onClick ToggledFavorite
                , class "btn btn-outline-primary btn-sm pull-xs-right"
                ]
                [ i [ class "ion-heart" ] []
                , text (String.fromInt article.favoritesCount)
                ]
            ]
        , a [ A.href <| Route.toHref (Route.ViewArticle article.slug), class "preview-link" ]
            [ h1 [] [ text article.title ]
            , p [] [ text article.description ]
            , span [] [ text "Read more..." ]
            ]
        ]
