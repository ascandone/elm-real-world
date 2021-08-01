module View.ArticleMeta exposing (view)

import Data.Article exposing (Article)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events as E
import Html.Lazy exposing (lazy)
import Misc
import Route
import View.FollowButton


type Msg
    = ClickedFollow
    | ClickedFavorite


view_ : Article -> Html Msg
view_ ({ author } as article) =
    div [ class "article-meta" ]
        [ a [ A.href (Route.toHref <| Route.Profile author.username) ]
            [ img [ A.src (Misc.defaultImage author.image) ] [] ]
        , div [ class "info" ]
            [ a [ class "author", A.href (Route.toHref <| Route.Profile author.username) ] [ text author.username ]
            , span [ class "date" ] [ text article.createdAt ] --TODO
            ]
        , View.FollowButton.view { onFollow = ClickedFollow } author
        , button
            [ class "btn btn-sm"
            , class <|
                if article.favorited then
                    "btn-primary"

                else
                    "btn-outline-primary"
            , E.onClick ClickedFavorite
            ]
            [ i [ class "ion-heart" ] []
            , text "Favorite Post"
            , span [ class "counter" ] [ text ("(" ++ String.fromInt article.favoritesCount ++ ")") ]
            ]
        ]


view : { onClickedFavorite : msg, onClickedFollow : msg } -> Article -> Html msg
view props article =
    lazy view_ article
        |> Html.map
            (\msg ->
                case msg of
                    ClickedFavorite ->
                        props.onClickedFavorite

                    ClickedFollow ->
                        props.onClickedFollow
            )
