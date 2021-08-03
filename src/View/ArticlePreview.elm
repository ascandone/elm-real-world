module View.ArticlePreview exposing (view)

import Api.Articles exposing (author)
import Data.Article exposing (Article)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy2)
import Misc exposing (defaultImage)
import Route
import Time
import View.Posix


type Msg
    = ToggledFavorite


view_ : Maybe Time.Zone -> Article -> Html Msg
view_ timeZone ({ author } as article) =
    div [ class "article-preview" ]
        [ div [ class "article-meta" ]
            [ a [ A.href <| Route.toHref (Route.Profile author.username) ]
                [ img [ A.src (defaultImage author.image) ] [] ]
            , div [ class "info" ]
                [ a [ A.href <| Route.toHref (Route.Profile author.username), class "author" ] [ text author.username ]
                , span [ class "date" ] [ View.Posix.view timeZone article.createdAt ]
                ]
            , button
                [ onClick ToggledFavorite
                , class "btn btn-sm pull-xs-right"
                , class <|
                    if article.favorited then
                        "btn-primary"

                    else
                        "btn-outline-primary"
                ]
                [ i [ class "ion-heart" ] []
                , text (String.fromInt article.favoritesCount)
                ]
            ]
        , a [ A.href <| Route.toHref (Route.Article article.slug), class "preview-link" ]
            [ h1 [] [ text article.title ]
            , p [] [ text article.description ]
            , span [] [ text "Read more..." ]
            , case article.tagList of
                [] ->
                    text ""

                _ ->
                    ul []
                        (article.tagList
                            |> List.map
                                (\tag ->
                                    li [ class "tag-default tag-pill tag-outline" ]
                                        [ text tag ]
                                )
                        )
            ]
        ]


view : { r | onToggleFavorite : Article -> msg } -> Maybe Time.Zone -> Article -> Html msg
view { onToggleFavorite } timeZone article =
    Html.map
        (\ToggledFavorite -> onToggleFavorite article)
        (lazy2 view_ timeZone article)
