module Page.Profile exposing
    ( Event
    , Model
    , Msg
    , init
    , update
    , view
    )

import Api
import Api.Articles exposing (limit)
import Api.Articles.Slug_.Favorite
import Api.Profiles.Username_
import Api.Profiles.Username_.Follow
import App
import Browser.Navigation
import Data.Article as Article exposing (Article, Collection)
import Data.Async as Async exposing (Async(..))
import Data.Profile exposing (Profile)
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Misc exposing (jumpToTop)
import Route
import View.ArticlePreview
import View.FollowButton
import View.NavPills
import View.Pagination exposing (Pagination)


type alias Event =
    Never


type Feed
    = MyArticles
    | FavoriteArticles


type alias Model =
    { asyncProfile : Async Profile
    , asyncArticles : Async Collection
    , feed : Feed
    , pagination : Pagination
    }


fetchFeed : String -> Feed -> Pagination -> Cmd Msg
fetchFeed username feed pagination =
    let
        { offset, limit } =
            View.Pagination.getData pagination

        params =
            List.append
                [ Api.Articles.limit limit
                , Api.Articles.offset offset
                ]
                (case feed of
                    MyArticles ->
                        [ Api.Articles.author username
                        ]

                    FavoriteArticles ->
                        [ Api.Articles.favorited username
                        ]
                )
    in
    Api.Articles.get params |> Api.send GotArticles


init : { username : String } -> ( Model, Cmd Msg )
init { username } =
    let
        model =
            { asyncProfile = Pending
            , asyncArticles = Pending
            , feed = MyArticles
            , pagination = View.Pagination.init { pageSize = 10 }
            }
    in
    ( model
    , Cmd.batch
        [ Api.Profiles.Username_.get username |> Api.send GotProfile
        , fetchFeed username model.feed model.pagination
        ]
    )


type Msg
    = GotProfile (Api.Response Profile)
    | GotArticles (Api.Response Article.Collection)
    | ClickedFollow Profile
    | ToggleFavorite Article
    | SetFeed Feed
    | SelectedPagination View.Pagination.Pagination
    | SetViewport
    | GotFollowResponse (Api.Response Profile)
    | GotFavoriteResponse (Api.Response Article)


update :
    { r
        | mUser : Maybe User
        , key : Browser.Navigation.Key
    }
    -> { username : String }
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Maybe Event )
update { mUser, key } { username } msg model =
    case msg of
        SetViewport ->
            App.pure model

        SetFeed feed ->
            App.pure { model | feed = feed }

        ToggleFavorite article ->
            case mUser of
                Nothing ->
                    App.pure model
                        |> App.withCmd (Browser.Navigation.pushUrl key (Route.toHref Route.Login))

                Just user ->
                    let
                        action =
                            if article.favorited then
                                Api.Articles.Slug_.Favorite.delete

                            else
                                Api.Articles.Slug_.Favorite.post
                    in
                    App.pure model
                        |> App.withCmd (action user article.slug |> Api.send GotFavoriteResponse)

        GotFavoriteResponse res ->
            case res of
                Err err ->
                    App.pure model
                        |> App.withCmd (Api.logError err)

                Ok newArticle ->
                    case model.asyncArticles of
                        Async.GotData collection ->
                            App.pure
                                { model
                                    | asyncArticles = GotData (Article.replaceArticle newArticle collection)
                                }

                        _ ->
                            App.pure model

        GotProfile res ->
            App.pure { model | asyncProfile = Async.fromResponse res }
                |> App.withCmd (Api.logIfError res)

        ClickedFollow profile ->
            case mUser of
                Nothing ->
                    App.pure model
                        |> App.withCmd (Browser.Navigation.pushUrl key (Route.toHref Route.Login))

                Just user ->
                    let
                        action =
                            if profile.following then
                                Api.Profiles.Username_.Follow.delete

                            else
                                Api.Profiles.Username_.Follow.post
                    in
                    App.pure model
                        |> App.withCmd (action user profile.username |> Api.send GotFollowResponse)

        GotFollowResponse res ->
            case res of
                Ok profile ->
                    App.pure { model | asyncProfile = GotData profile }

                Err err ->
                    App.pure model
                        |> App.withCmd (Api.logError err)

        GotArticles res ->
            App.pure { model | asyncArticles = Async.fromResponse res }
                |> App.withCmd (jumpToTop SetViewport)

        SelectedPagination pagination ->
            App.pure { model | pagination = pagination }
                |> App.withCmd (fetchFeed username model.feed model.pagination)


view : Model -> ( Maybe String, Html Msg )
view model =
    ( Just <|
        case model.asyncProfile of
            Async.GotData { username } ->
                username

            _ ->
                "Profile"
    , div [ class "profile-page" ]
        [ case model.asyncProfile of
            Async.GotData profile ->
                viewUserInfo profile

            _ ->
                text ""
        , div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ] <|
                    List.append
                        [ div [ class "articles-toggle" ]
                            [ View.NavPills.view model.feed
                                { onSelected = SetFeed }
                                [ { item = MyArticles, text = "My Articles" }
                                , { item = FavoriteArticles, text = "Favorite Articles" }
                                ]
                            ]
                        ]
                        (case model.asyncArticles of
                            Pending ->
                                [ text "Loading..." ]

                            GotData collection ->
                                List.append
                                    (collection.articles
                                        |> List.map
                                            (View.ArticlePreview.view
                                                { onToggleFavorite = ToggleFavorite }
                                            )
                                    )
                                    [ View.Pagination.view
                                        { articlesCount = collection.articlesCount
                                        , pagination = model.pagination
                                        , onSelected = SelectedPagination
                                        }
                                    ]

                            GotErr _ ->
                                Debug.todo "handle err"
                        )
                ]
            ]
        ]
    )


viewUserInfo : Profile -> Html Msg
viewUserInfo profile =
    div [ class "user-info" ]
        [ div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                    [ img [ class "user-img", A.src (Misc.defaultImage profile.image) ] []
                    , h4 [] [ text profile.username ]
                    , case profile.bio of
                        Nothing ->
                            text ""

                        Just bio ->
                            p [] [ text bio ]
                    , View.FollowButton.view
                        { onFollow = ClickedFollow profile }
                        profile
                    ]
                ]
            ]
        ]
