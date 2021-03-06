module Page.Home exposing
    ( Model
    , Msg
    , init
    , specs
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
import Expect
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events as E
import Html.Lazy exposing (lazy2)
import Misc exposing (checkUrl, dataTest, jumpToTop)
import Route
import Test exposing (Test)
import Test.Html.Event as HEvent
import Test.Html.Query as HQuery
import Test.Html.Selector as HSelector
import Time
import Url.Parser as UP exposing ((</>), (<?>))
import Url.Parser.Query as UPQ
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
    | GotArticles FeedType (Api.Response Article.Collection)
    | SelectedFeed FeedType
    | ToggleFavoriteArticle (Maybe User) Article
    | SelectedPagination Pagination
    | SetViewport
    | ToggleFavoriteArticleResponse (Api.Response Article)


initialPagination : Pagination
initialPagination =
    View.Pagination.init { pageSize = 10 }


initModel : Model
initModel =
    { tags = Pending
    , feedType = GlobalFeed
    , pagination = initialPagination
    , articles = Pending
    }


initEffs : List (Effect Msg)
initEffs =
    [ Api.Tags.get |> Api.send GotTags
    , fetchArticles initModel
    ]


init : ( Model, List (Effect Msg) )
init =
    ( initModel
    , initEffs
    )


fetchArticles : Model -> Effect Msg
fetchArticles model =
    let
        data =
            View.Pagination.getData model.pagination
    in
    Api.send (GotArticles model.feedType) <|
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


withFetchArticles : ( Model, List (Effect Msg), Maybe Never ) -> ( Model, List (Effect Msg), Maybe Never )
withFetchArticles (( model, _, _ ) as app) =
    app
        |> App.withEff (fetchArticles model)


update : Msg -> Model -> ( Model, List (Effect Msg), Maybe Never )
update msg model =
    case msg of
        SetViewport ->
            App.pure model

        GotTags res ->
            App.pure { model | tags = Async.fromResponse res }
                |> App.withEff (Api.logIfError res)

        GotArticles feed res ->
            if model.feedType == feed then
                App.pure { model | articles = Async.fromResponse res }
                    |> App.withEff (Api.logIfError res)
                    |> App.withEff (jumpToTop SetViewport)

            else
                App.pure model

        SelectedFeed feed ->
            App.pure
                { model
                    | feedType = feed
                    , pagination = initialPagination
                }
                |> withFetchArticles

        SelectedPagination pagination ->
            App.pure { model | pagination = pagination }
                |> withFetchArticles

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
        [ A.href ""
        , class "tag-pill tag-default"
        , E.onClick (SelectedFeed (TagFeed tag))
        , dataTest ("tag-pill-" ++ tag)
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



-- ###  TEST


getEffs : ( a, b, c ) -> b
getEffs ( _, effs, _ ) =
    effs


matchArticles :
    { offset : Int
    , limit : Int
    , tag : Maybe String
    }
    -> UP.Parser (Bool -> a) a
matchArticles args =
    (UP.s "api" </> UP.s "articles")
        <?> UPQ.int "offset"
        <?> UPQ.int "limit"
        <?> UPQ.string "tag"
        |> UP.map
            (\offset limit tag ->
                (offset == Just args.offset)
                    && (limit == Just args.limit)
                    && (tag == args.tag)
            )


specs : Test
specs =
    Test.concat
        [ Test.test "Fetch tags on init" <|
            \() ->
                init
                    |> Tuple.second
                    |> List.any
                        (\eff ->
                            case eff of
                                Effect.HttpRequest req ->
                                    (req.method == "GET")
                                        && (req.url == Api.apiBase ++ "/api/tags")

                                _ ->
                                    False
                        )
                    |> Expect.true "cannot find Http request"
        , Test.test "Fetch article on init" <|
            \() ->
                init
                    |> Tuple.second
                    |> List.any
                        (\eff ->
                            case eff of
                                Effect.HttpRequest req ->
                                    (req.method == "GET")
                                        && checkUrl req.url
                                            (matchArticles
                                                { offset = 0
                                                , limit = 10
                                                , tag = Nothing
                                                }
                                            )

                                _ ->
                                    False
                        )
                    |> Expect.true "cannot find Http request"
        , Test.describe "Fetch right feed when change tab"
            [ Test.test "Tag feed" <|
                \() ->
                    initModel
                        |> update (SelectedFeed (TagFeed "some-tag"))
                        |> getEffs
                        |> List.any
                            (\eff ->
                                case eff of
                                    Effect.HttpRequest req ->
                                        (req.method == "GET")
                                            && checkUrl req.url
                                                (matchArticles
                                                    { offset = 0
                                                    , limit = 10
                                                    , tag = Just "some-tag"
                                                    }
                                                )

                                    _ ->
                                        False
                            )
                        |> Expect.true "cannot find Http request"
            , Test.todo "Global feed"
            , Test.todo "Personal feed"
            ]
        , Test.describe "Fetch right feed when change pagination"
            [ Test.todo "t1"
            ]
        , Test.test "clicking tag changes tab" <|
            let
                page =
                    view
                        { mUser = Nothing, timeZone = Just Time.utc }
                        { initModel | tags = GotData [ "first-tag", "second-tag" ] }
                        |> Tuple.second
                        |> HQuery.fromHtml
                        |> HQuery.find [ HSelector.attribute (dataTest "tag-pill-first-tag") ]
                        |> HEvent.simulate HEvent.click
                        |> HEvent.expect (SelectedFeed (TagFeed "first-tag"))
            in
            \() -> page
        ]
