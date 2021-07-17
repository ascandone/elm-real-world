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
import Html exposing (..)
import Html.Attributes as A exposing (class)
import Http
import Ports
import Process
import Task
import View.ArticlePreview


type alias Model =
    { tags : Maybe (List String)
    }


type Msg
    = GotTags (Api.Response (List String))
    | Noop


init : ( Model, Cmd Msg )
init =
    ( { tags = Nothing
      }
    , Cmd.batch
        [ Api.Tags.get |> Api.send GotTags
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Never )
update msg model =
    case msg of
        Noop ->
            App.pure model

        GotTags res ->
            case res of
                Ok tags ->
                    App.pure { model | tags = Just tags }

                Err _ ->
                    App.pure model
                        |> App.withCmd (Ports.logError "tags response error")


viewTagPill : String -> Html msg
viewTagPill tag =
    a
        [ A.href "" -- TODO route on tag
        , class "tag-pill tag-default"
        ]
        [ text tag ]


view : Model -> Html Msg
view model =
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
                        [ ul
                            [ class "nav nav-pills outline-active"
                            ]
                            [ li
                                [ class "nav-item"
                                ]
                                [ a
                                    [ class "nav-link disabled"
                                    , A.href ""
                                    ]
                                    [ text "Your Feed" ]
                                ]
                            , li
                                [ class "nav-item"
                                ]
                                [ a
                                    [ class "nav-link active"
                                    , A.href ""
                                    ]
                                    [ text "Global Feed" ]
                                ]
                            ]
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
