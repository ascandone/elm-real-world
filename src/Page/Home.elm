module Page.Home exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Api exposing (Response)
import Api.Tags
import App
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Html.Events as E
import Http
import Ports
import Process
import Task
import View.ArticlePreview
import View.NavPills


type FeedType
    = YourFeed User
    | GlobalFeed
    | TagFeed String


type alias Model =
    { tags : Maybe (List String)
    , feed : FeedType
    }


type Msg
    = GotTags (Api.Response (List String))
    | SelectedFeed FeedType
    | Noop


init : ( Model, Cmd Msg )
init =
    ( { tags = Nothing
      , feed = GlobalFeed
      }
    , Cmd.batch
        [ Api.Tags.get |> Api.send GotTags
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Never )
update msg model =
    case msg of
        GotTags res ->
            case res of
                Ok tags ->
                    App.pure { model | tags = Just tags }

                Err _ ->
                    App.pure model
                        |> App.withCmd (Ports.logError "tags response error")

        SelectedFeed feed ->
            -- TODO fetch
            App.pure { model | feed = feed }

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


view : { r | mUser : Maybe User } -> Model -> Html Msg
view { mUser } model =
    div
        [ class "home-page"
        ]
        [ div
            [ class "banner"
            ]
            [ div
                [ class "container"
                ]
                [ h1
                    [ class "logo-font"
                    ]
                    [ text "conduit" ]
                , p []
                    [ text "A place to share your knowledge." ]
                ]
            ]
        , div
            [ class "container page"
            ]
            [ div
                [ class "row"
                ]
                [ div
                    [ class "col-md-9"
                    ]
                    [ div
                        [ class "feed-toggle"
                        ]
                        [ View.NavPills.view
                            model.feed
                            { onSelected = SelectedFeed }
                            ([ mUser |> Maybe.map (\u -> { item = YourFeed u, text = "Your Feed" })
                             , Just { item = GlobalFeed, text = "Global Feed" }
                             , case model.feed of
                                (TagFeed t) as f ->
                                    Just { item = f, text = "#" ++ t }

                                _ ->
                                    Nothing
                             ]
                                |> List.filterMap identity
                            )
                        ]
                    , View.ArticlePreview.view
                        { onToggleFavorite = Noop }
                        { slug = "String"
                        , title = "String"
                        , description = "String"
                        , body = "String"
                        , tagList = [ "String" ]
                        , createdAt = "String"
                        , updatedAt = "String"
                        , favorited = True
                        , favoritesCount = 32
                        , author =
                            { username = "String"
                            , bio = "String"
                            , image = Nothing
                            , following = True
                            }
                        }
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
