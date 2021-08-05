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
import Data.Article as Article exposing (Article)
import Data.Async as Async exposing (Async(..))
import Data.User exposing (User)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events as E
import Html.Lazy exposing (lazy2)
import Misc exposing (jumpToTop)
import Route
import Time
import View.ArticlePreview
import View.NavPills
import View.Pagination exposing (Pagination)


type FeedType
    = YourFeed User
    | GlobalFeed
    | TagFeed String


type alias Model =
    { tags : Async (List String)
    , articles : Async Article.Collection
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


init : ( Model, List (Effect Msg) )
init =
    let
        model =
            { tags = Pending
            , feedType = GlobalFeed
            , pagination = initialPagination
            , articles = Pending
            }
    in
    ( model
    , [ Api.Tags.get |> Api.send GotTags
      , fetchArticles model
      ]
    )


fetchArticles : Model -> Effect Msg
fetchArticles model =
    let
        data =
            View.Pagination.getData model.pagination
    in
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


update : Msg -> Model -> ( Model, List (Effect Msg), Maybe Never )
update msg model =
    case msg of
        SetViewport ->
            App.pure model

        GotTags res ->
            App.pure { model | tags = Async.fromResponse res }
                |> App.withEff (Api.logIfError res)

        GotArticles res ->
            App.pure { model | articles = Async.fromResponse res }
                |> App.withEff (Api.logIfError res)
                |> App.withEff (jumpToTop SetViewport)

        SelectedFeed feed ->
            App.pure { model | feedType = feed, pagination = initialPagination }
                |> App.withEff (fetchArticles model)

        SelectedPagination pagination ->
            App.pure { model | pagination = pagination }
                |> App.withEff (fetchArticles model)

        ToggleFavoriteArticle mUser article ->
            case mUser of
                Nothing ->
                    App.pure model
                        |> App.withEff (Effect.NavPushUrl <| Route.toHref Route.Login)

                Just user ->
                    App.pure model
                        |> App.withEff
                            (Api.Articles.Slug_.Favorite.post user article.slug
                                |> Api.send ToggleFavoriteArticleResponse
                            )

        ToggleFavoriteArticleResponse res ->
            case ( res, model.articles ) of
                ( Ok newArticle, GotData collection ) ->
                    App.pure
                        { model
                            | articles = GotData (Article.replaceArticle newArticle collection)
                        }

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


view : { r | mUser : Maybe User, timeZone : Maybe Time.Zone } -> Model -> ( Maybe String, Html Msg )
view { mUser, timeZone } model =
    ( Nothing
    , div [ class "home-page" ]
        [ viewBanner
        , div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ]
                    [ lazy2 viewFeedToggle mUser model.feedType
                    , div [] <|
                        case model.articles of
                            Pending ->
                                [ text "Loading.." ]

                            GotErr _ ->
                                [ text "error." ]

                            GotData collection ->
                                List.concat
                                    [ List.map
                                        (View.ArticlePreview.view
                                            { onToggleFavorite = ToggleFavoriteArticle mUser }
                                            timeZone
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
                            Pending ->
                                text "Loading tags"

                            GotErr _ ->
                                text "Error loading tags"

                            GotData tags ->
                                div [ class "tag-list" ]
                                    (tags |> List.map viewTagPill)
                        ]
                    ]
                ]
            ]
        ]
    )
