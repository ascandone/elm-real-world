module Page.Home exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Api
import Api.Articles
import Api.Articles.Feed
import Api.Articles.Slug_.Favorite
import Api.Tags
import App
import Browser.Navigation
import Data.Article as Article exposing (Article)
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events as E
import Html.Lazy exposing (lazy2)
import Misc exposing (jumpToTop)
import Ports
import Route
import View.ArticlePreview
import View.NavPills
import View.Pagination exposing (Pagination)


type FeedType
    = YourFeed User
    | GlobalFeed
    | TagFeed String


type alias Model =
    { tags : Maybe (List String)
    , articles : Maybe (Api.Response Article.Collection)
    , feedType : FeedType
    , pagination : Pagination
    }


type Msg
    = GotTags (Api.Response (List String))
    | GotArticles (Api.Response Article.Collection)
    | SelectedFeed FeedType
    | ToggleFavoriteArticle (Maybe User) Article
    | SelectedPagination Pagination
    | SetViewport
    | ToggleFavoriteArticleResponse (Api.Response Article)


initialPagination : Pagination
initialPagination =
    View.Pagination.init { pageSize = 10 }


init : ( Model, Cmd Msg )
init =
    ( { tags = Nothing
      , feedType = GlobalFeed
      , pagination = initialPagination
      , articles = Nothing
      }
    , Cmd.batch
        [ Api.Tags.get |> Api.send GotTags
        , Api.Articles.get [] |> Api.send GotArticles
        ]
    )


fetchArticles : ( Model, Cmd Msg, evt ) -> ( Model, Cmd Msg, evt )
fetchArticles ( model, cmd, evt ) =
    let
        data =
            View.Pagination.getData model.pagination

        fetchCmd =
            Api.send GotArticles <|
                case model.feedType of
                    GlobalFeed ->
                        Api.Articles.get
                            [ Api.Articles.limit data.limit
                            , Api.Articles.offset data.offset
                            ]

                    TagFeed tag ->
                        Api.Articles.get
                            [ Api.Articles.limit data.limit
                            , Api.Articles.offset data.offset
                            , Api.Articles.tag tag
                            ]

                    YourFeed user ->
                        Api.Articles.Feed.get user
                            [ Api.Articles.Feed.limit data.limit
                            , Api.Articles.Feed.offset data.offset
                            ]
    in
    ( model, Cmd.batch [ cmd, fetchCmd ], evt )


update :
    { r
        | key : Browser.Navigation.Key
    }
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Maybe Never )
update { key } msg model =
    case msg of
        SetViewport ->
            App.pure model

        GotTags res ->
            case res of
                Ok tags ->
                    App.pure { model | tags = Just tags }

                Err e ->
                    App.pure model
                        |> App.withCmd (Api.logError e)

        GotArticles res ->
            -- TODO handle err
            let
                ret =
                    App.pure { model | articles = Just res }
            in
            case res of
                Err e ->
                    ret |> App.withCmd (Api.logError e)

                _ ->
                    ret
                        |> App.withCmd (jumpToTop SetViewport)

        SelectedFeed feed ->
            App.pure { model | feedType = feed, pagination = initialPagination }
                |> fetchArticles

        SelectedPagination pagination ->
            App.pure { model | pagination = pagination }
                |> fetchArticles

        ToggleFavoriteArticle mUser article ->
            case mUser of
                Nothing ->
                    App.pure model
                        |> App.withCmd (Browser.Navigation.pushUrl key (Route.toHref Route.Login))

                Just user ->
                    App.pure model
                        |> App.withCmd
                            (Api.Articles.Slug_.Favorite.post user article.slug
                                |> Api.send ToggleFavoriteArticleResponse
                            )

        ToggleFavoriteArticleResponse res ->
            case ( res, model.articles ) of
                ( Ok newArticle, Just (Ok collection) ) ->
                    let
                        newCollection =
                            collection.articles
                                |> List.map
                                    (\article ->
                                        if article.slug /= newArticle.slug then
                                            article

                                        else
                                            newArticle
                                    )
                    in
                    App.pure { model | articles = Just (Ok { collection | articles = newCollection }) }

                -- TODO handle err
                ( Err _, _ ) ->
                    App.pure model

                _ ->
                    App.pure model


viewTagPill : String -> Html Msg
viewTagPill tag =
    a
        [ A.href "" -- TODO route on tag
        , class "tag-pill tag-default"
        , E.onClick (SelectedFeed (TagFeed tag))
        ]
        [ text tag ]


viewBanner : Html msg
viewBanner =
    div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ] [ text "conduit" ]
            , p [] [ text "A place to share your knowledge." ]
            ]
        ]


viewFeedToggle : Maybe User -> FeedType -> Html Msg
viewFeedToggle mUser feed =
    div [ class "feed-toggle" ]
        [ View.NavPills.view
            feed
            { onSelected = SelectedFeed }
            ([ mUser |> Maybe.map (\u -> { item = YourFeed u, text = "Your Feed" })
             , Just { item = GlobalFeed, text = "Global Feed" }
             , case feed of
                (TagFeed t) as f ->
                    Just { item = f, text = "#" ++ t }

                _ ->
                    Nothing
             ]
                |> List.filterMap identity
            )
        ]


view : { r | mUser : Maybe User } -> Model -> ( Maybe String, Html Msg )
view { mUser } model =
    ( Nothing
    , div [ class "home-page" ]
        [ viewBanner
        , div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ]
                    [ lazy2 viewFeedToggle mUser model.feedType
                    , div [] <|
                        case model.articles of
                            Nothing ->
                                [ text "Loading.." ]

                            Just (Err _) ->
                                [ text "error." ]

                            Just (Ok collection) ->
                                List.concat
                                    [ List.map
                                        (\article ->
                                            View.ArticlePreview.view
                                                { onToggleFavorite = ToggleFavoriteArticle mUser article }
                                                article
                                        )
                                        collection.articles
                                    , [ View.Pagination.view
                                            { articlesCount = collection.articlesCount
                                            , pagination = model.pagination
                                            , onSelected = SelectedPagination
                                            }
                                      ]
                                    ]
                    ]
                , div [ class "col-md-3" ]
                    [ div [ class "sidebar" ]
                        [ p [] [ text "Popular Tags" ]
                        , case model.tags of
                            Nothing ->
                                text "Loading tags"

                            Just tags ->
                                div [ class "tag-list" ]
                                    (tags |> List.map viewTagPill)
                        ]
                    ]
                ]
            ]
        ]
    )
