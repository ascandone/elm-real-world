module View.ArticleMeta exposing (view)

import Data.Article exposing (Article)
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events as E
import Html.Lazy exposing (lazy3)
import Misc
import Route
import Time
import View.FollowButton
import View.Posix


type Msg
    = ClickedFollow
    | ClickedFavorite
    | ClickedDeleteArticle User


viewDeleteBtn : User -> Html Msg
viewDeleteBtn user =
    button
        [ class "btn btn-sm btn-outline-danger"
        , E.onClick (ClickedDeleteArticle user)
        ]
        [ i [ class "ion-trash-a" ] []
        , text "Delete Article"
        ]


viewEditBtn : Article -> Html Msg
viewEditBtn article =
    a
        [ A.href <| Route.toHref (Route.Editor article.slug)
        , class "btn btn-sm btn-outline-secondary"
        ]
        [ text "Edit Article" ]


viewLoggedInBtns : User -> Article -> List (Html Msg)
viewLoggedInBtns user article =
    [ viewEditBtn article
    , viewDeleteBtn user
    ]


viewFavoriteBtn : Article -> Html Msg
viewFavoriteBtn article =
    button
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


viewExternalArticleBtns : Article -> List (Html Msg)
viewExternalArticleBtns ({ author } as article) =
    [ View.FollowButton.view { onFollow = ClickedFollow } author
    , viewFavoriteBtn article
    ]


view_ : Maybe Time.Zone -> Maybe User -> Article -> Html Msg
view_ mTimeZone mUser ({ author } as article) =
    div [ class "article-meta" ]
        (List.append
            [ a [ A.href (Route.toHref <| Route.Profile author.username) ]
                [ img [ A.src (Misc.defaultImage author.image) ] [] ]
            , div [ class "info" ]
                [ a [ class "author", A.href (Route.toHref <| Route.Profile author.username) ] [ text author.username ]
                , span [ class "date" ] [ View.Posix.view mTimeZone article.createdAt ]
                ]
            ]
            (case mUser of
                Nothing ->
                    viewExternalArticleBtns article

                Just user ->
                    if article.author.username == user.username then
                        viewLoggedInBtns user article

                    else
                        viewExternalArticleBtns article
            )
        )


view :
    { onClickedFavorite : msg
    , onClickedFollow : msg
    , onClickedDeleteArticle : User -> msg
    }
    -> Maybe Time.Zone
    -> Maybe User
    -> Article
    -> Html msg
view props mTimeZone mUser article =
    lazy3 view_ mTimeZone mUser article
        |> Html.map
            (\msg ->
                case msg of
                    ClickedFavorite ->
                        props.onClickedFavorite

                    ClickedFollow ->
                        props.onClickedFollow

                    ClickedDeleteArticle user ->
                        props.onClickedDeleteArticle user
            )
