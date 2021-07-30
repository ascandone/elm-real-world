module Page.Article exposing
    ( Event
    , Model
    , Msg
    , init
    , update
    , view
    )

import Api
import Api.Articles
import Api.Articles.Slug_
import Api.Profiles.Username_.Follow
import App
import Data.Article exposing (Article)
import Data.Comment exposing (Comment)
import Data.Profile exposing (Profile)
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class, href)
import Markdown
import Misc
import Route
import View.ArticleMeta


type alias Event =
    Never


type alias Model =
    { slug : String
    , asyncArticle : Maybe (Api.Response Article)
    , asyncComments : Maybe (Api.Response (List Comment))
    }


type Msg
    = GotArticle (Api.Response Article)
    | ClickedFavorite (Maybe User)
    | ClickedFollow (Maybe User)
    | GotFavoriteResponse (Api.Response Profile)


init : String -> ( Model, Cmd Msg )
init slug =
    ( { slug = slug
      , asyncArticle = Nothing
      , asyncComments = Nothing
      }
    , Api.Articles.Slug_.get slug |> Api.send GotArticle
    )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Event )
update msg model =
    case msg of
        GotArticle response ->
            App.pure { model | asyncArticle = Just response }

        ClickedFollow mUser ->
            case ( model.asyncArticle, mUser ) of
                ( Just (Ok article), Just user ) ->
                    let
                        action =
                            if article.author.following then
                                Api.Profiles.Username_.Follow.delete

                            else
                                Api.Profiles.Username_.Follow.post
                    in
                    App.pure model
                        |> App.withCmd
                            (action user article.author.username
                                |> Api.send GotFavoriteResponse
                            )

                ( _, Nothing ) ->
                    Debug.todo "redirect to login"

                _ ->
                    App.pure model

        ClickedFavorite _ ->
            Debug.todo "fav"

        GotFavoriteResponse res ->
            case ( model.asyncArticle, res ) of
                ( _, Err _ ) ->
                    Debug.todo "handle err"

                ( Just (Ok article), Ok profile ) ->
                    App.pure { model | asyncArticle = Just (Ok { article | author = profile }) }

                _ ->
                    App.pure model


viewCardCommentForm : User -> Html msg
viewCardCommentForm user =
    form [ class "card comment-form" ]
        [ div [ class "card-block" ]
            [ textarea [ class "form-control", A.placeholder "Write a comment...", A.rows 3 ] []
            ]
        , div [ class "card-footer" ]
            [ img [ class "comment-author-img", A.src "http://i.imgur.com/Qr71crq.jpg" ] []
            , button [ class "btn btn-sm btn-primary" ] [ text "Post Comment" ]
            ]
        ]


viewCommentCard : Comment -> Html msg
viewCommentCard ({ author } as comment) =
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ p [ class "card-text" ] [ text comment.body ]
            ]
        , div [ class "card-footer" ]
            [ a [ class "comment-author", href (Route.toHref (Route.ViewProfile author.username)) ]
                [ img [ class "comment-author-img", A.src (Misc.defaultImage author.image) ] []
                ]
            , a [ class "comment-author", href (Route.toHref (Route.ViewProfile author.username)) ] [ text author.username ]
            , span [ class "date-posted" ] [ text comment.createdAt ] -- TODO format
            ]
        ]


view : { r | mUser : Maybe User } -> Model -> Html Msg
view { mUser } model =
    case model.asyncArticle of
        Nothing ->
            text "Loading..."

        Just (Err _) ->
            text "Error"

        Just (Ok article) ->
            div [ class "article-page" ]
                [ div [ class "banner" ]
                    [ div [ class "container" ]
                        [ h1 [] [ text article.title ]
                        , View.ArticleMeta.view
                            { onClickedFavorite = ClickedFavorite mUser
                            , onClickedFollow = ClickedFollow mUser
                            }
                            article
                        ]
                    ]
                , div [ class "container page" ]
                    [ div [ class "row article-content" ]
                        [ Markdown.toHtml [ class "col-md-12" ] article.body ]
                    , hr [] []
                    , div [ class "article-actions" ]
                        [ View.ArticleMeta.view
                            { onClickedFavorite = ClickedFavorite mUser
                            , onClickedFollow = ClickedFollow mUser
                            }
                            article
                        ]
                    , div [ class "row" ]
                        [ div [ class "col-xs-12 col-md-8 offset-md-2" ] <|
                            List.append
                                [ case mUser of
                                    Nothing ->
                                        text ""

                                    Just user ->
                                        viewCardCommentForm user
                                ]
                                (case model.asyncComments of
                                    Nothing ->
                                        []

                                    Just (Err _) ->
                                        [ text "Error" ]

                                    Just (Ok comments) ->
                                        comments |> List.map viewCommentCard
                                )
                        ]
                    ]
                ]
